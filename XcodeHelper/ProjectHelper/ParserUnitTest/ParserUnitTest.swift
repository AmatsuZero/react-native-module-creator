//
//  ParserUnitTest.swift
//  ParserUnitTest
//
//  Created by Jiang,Zhenhua on 2018/6/28.
//  Copyright © 2018年 Jiang,Zhenhua. All rights reserved.
//

import XCTest

class ParserUnitTest: XCTestCase {
    
    var originalPodFile: String?
    lazy var podFileURL: URL? = {
        let testBundle = Bundle(for: type(of: self) as AnyClass)
        return testBundle.url(forResource: "Podfile", withExtension: nil)
    }()
    var tempGitDir: String?
    
    override func setUp() {
        super.setUp()
        originalPodFile = nil
        tempGitDir = nil
    }
    
    override func tearDown() {
        super.tearDown()
        if let file = originalPodFile, let url = podFileURL {
            // 还原原来的文件
            try? file.write(to: url, atomically: true, encoding: .utf8)
        }
        // 删除临时文件夹
        if let path = tempGitDir {
            try? FileManager.default.removeItem(at: URL(fileURLWithPath: path))
        }
    }
    
    func testPodfileModify() {
        XCTAssertNotNil(podFileURL)
        // 记录原始的PodFile样式
        originalPodFile = try? String(contentsOf: podFileURL!)
        do {
            let module = RNCocoapodsHelper(podFilePath: podFileURL!.path)
            try module.addDependecy(repoName: "AFNetworking",
                                    target: "MyApp",
                                    version: .optimistic("3.1"))
        } catch(let e) {
            XCTFail(e.localizedDescription)
        }
    }
    
    //MARK: Git解析测试
    //FIXME: clone会有奇怪的报错……
    func testGitSubmodule() {
        // 创建一个临时的测试文件夹
        tempGitDir = NSSearchPathForDirectoriesInDomains(.documentDirectory,
                                                       .userDomainMask,
                                                       true).first
        tempGitDir?.append("/Test")
        XCTAssertNotNil(tempGitDir)
        do {
            try FileManager.default.createDirectory(at: URL(fileURLWithPath: tempGitDir!),
                withIntermediateDirectories: false, attributes: nil)
            // 克隆测试项目
            try? cmd(command: "git clone https://github.com/AmatsuZero/react-native-module-creator.git", path: tempGitDir!)
            let module = try RNSubmoduleHelper(rootPath: "\(tempGitDir!)/react-native-module-creator")
            try module.cloneSubmodule()
        } catch (let e) {
            XCTFail(e.localizedDescription)
        }
    }
    
    func cmd(command: String, path: String) throws {
        let process = Process()
        process.currentDirectoryURL = URL(fileURLWithPath: path)
        process.launchPath = "/bin/bash"
        process.arguments = ["-c", command]
        
        let pipe = Pipe()
        let error = Pipe()
        process.standardOutput = pipe
        process.standardError = error
        
        let file = pipe.fileHandleForReading
        process.launch()
        if let message = String(data: error.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8), !message.isEmpty {
            throw NSError(domain: "com.daubert", code: -1, userInfo: [NSLocalizedDescriptionKey: message])
        }
        let data = file.readDataToEndOfFile()
        if let message = String(data: data, encoding: .utf8) {
            print(message)
        }
    }
}
