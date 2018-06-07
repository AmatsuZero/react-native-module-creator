//
//  RNSubmoduleHelper.swift
//  ProjectHelper
//
//  Created by Jiang,Zhenhua on 2018/6/6.
//  Copyright © 2018年 Jiang,Zhenhua. All rights reserved.
//

import Foundation

class RNSubmoduleHelper {
    
    private(set) var dependencies = [String: URL]()
    private let rootPath: String
    private(set) var isExecuting = false
    private let task = OperationQueue()
    
    init(rootPath: String) throws {
        self.rootPath = rootPath
        let rootURL = URL(fileURLWithPath: rootPath)
        let path = URL(fileURLWithPath: ".gitmodules", relativeTo: rootURL)
        let content = try String(contentsOf: path)
        content.components(separatedBy: "\n")
            .filter { $0.hasPrefix("\tpath") }
            .map { $0.components(separatedBy: "=") }
            .map { $0.last?.trimmingCharacters(in: .whitespaces) }
            .compactMap { $0 }
            .map { URL(fileURLWithPath: $0, relativeTo: rootURL) }
            .forEach { dependencies[$0.lastPathComponent] = $0 }
    }
    
    func cloneSubmodule() throws {
        isExecuting = true
        let ret = dependencies.allSatisfy { (_, path) -> Bool in
            let fileManager = FileManager.default
            guard fileManager.fileExists(atPath: rootPath.appending("/\(path)")) else {
                isExecuting = false
                return false
            }
            let paths = try? fileManager.contentsOfDirectory(atPath: path.path)
            return paths?.isEmpty == false
        }
        guard !ret else {// 已经存在，无需再次克隆
            isExecuting = false
            return
        }
        try cmd(command: "git submodule init")
        try cmd(command: "git submodule update")
    }
    
    func cmd(command: String) throws {
        let process = Process()
        process.currentDirectoryURL = URL(fileURLWithPath: rootPath)
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


