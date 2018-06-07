//
//  RNProjectConfig.swift
//  ProjectHelper
//
//  Created by Jiang,Zhenhua on 2018/6/6.
//  Copyright © 2018年 Jiang,Zhenhua. All rights reserved.
//

import Foundation
import XcodeEditor

class RNProjectConfig {
    private(set) var group: XCGroup?
    private var name: String?
    private var path: String?
    private var exampleFoler: String?
    private var templateFolder: String?
    private var destionationPath: String?
    private var project: XCProject?
    private var carthageRepos: [String]?
    
    init(json: String) throws {
        if let dict = try JSONSerialization.jsonObject(with: json.data(using: .utf8)!, options: .allowFragments) as? [String: Any] {
            name = dict["name"] as? String
            path = dict["path"] as? String
            exampleFoler = dict["example"] as? String
            templateFolder = dict["template"] as? String
            carthageRepos = dict["carthage"] as? [String]
            if let folfer = templateFolder, let root = name {
                project = XCProject(filePath: folfer.appending("/TemplateLibrary.xcodeproj"))
                group = project?.groupWithPath(fromRoot: root)
            }
        }
    }
    
    //MARK: Project Files Manager
    @discardableResult
    func addObjc(class name: String, at path: String) throws -> XCClassDefinition? {
        guard let definition = XCClassDefinition(name: name, language: ClassDefinitionLanguage(0)) else {
            return nil
        }
        // read header file
        let folderRUL = URL(fileURLWithPath: path)
        let header = try String(contentsOf: folderRUL.appendingPathComponent("\(name).h"))
        definition.header = header
        let impl = try String(contentsOf: folderRUL.appendingPathComponent("\(name).m"))
        definition.source = impl
        group?.addClass(definition)
        project?.save()
        return definition
    }
    
    @discardableResult
    func addHeader(name: String, at path: String) throws -> XCSourceFileDefinition? {
        let content = try String(contentsOf: URL(fileURLWithPath: path))
        guard let header = XCSourceFileDefinition(name: "\(name).h", text: content, type: .SourceCodeHeader) else {
            return nil
        }
        group?.addSourceFile(header)
        project?.save()
        return header
    }
    
    @discardableResult
    func addSwiftFile(name: String, at path: String) throws -> XCSourceFileDefinition? {
        let content = try String(contentsOf: URL(fileURLWithPath: path))
        guard let header = XCSourceFileDefinition(name: "\(name).swift", text: content, type: .SourceCodeSwift) else {
            return nil
        }
        group?.addSourceFile(header)
        project?.save()
        return header
    }
    
    func addFramework(name: String, targetName:String = "TemplateLibrary")  {
        guard let libSrcFile = project?.file(withName: name),
            let target = project?.target(withName: targetName) else {
            return
        }
        target.addMember(libSrcFile)
        for (name, configuration) in target.configurations() {
            let headerPaths = NSArray(arrayLiteral: ["$(inherited)", "$(PROJECT_DIR)/\(name)"])
            configuration.addOrReplaceSetting(headerPaths as NSCopying,
                                              forKey: "LIBRARY_SEARCH_PATHS")
        }
    }
}
