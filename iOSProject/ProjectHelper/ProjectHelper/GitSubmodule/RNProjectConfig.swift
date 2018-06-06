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
        do {
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
        } catch (let error) {
            throw error;
        }
    }
    
    
}
