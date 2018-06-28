//
//  RNCocoapodsHelper.swift
//  ProjectHelper
//
//  Created by Jiang,Zhenhua on 2018/6/28.
//  Copyright © 2018年 Jiang,Zhenhua. All rights reserved.
//

import Foundation

enum RepoVersionControl {
    
    enum GitControl {
        case branch(String, String)
        case tag(String, String)
        case commit(String, String)
        
        var description: String {
            switch self {
            case .branch(let address, let branchName):
                return ", :git => '\(address)', :branch => '\(branchName)'"
            case .tag(let address, let tag):
                return ", :git => '\(address)', :tag => '\(tag)'"
            case .commit(let address, let commitHash):
                return ", :git => '\(address)', :commit => '\(commitHash)'"
            }
        }
    }
    
    case specify(String)
    case higher(String)
    case higherOrEqaulTo(String)
    case lower(String)
    case lowerOrEqualTo(String)
    case optimistic(String)
    case git(GitControl)
    case none
    
    var description: String {
        switch self {
        case .specify(let v): return v
        case .higher(let v): return ", '> \(v)'"
        case .higherOrEqaulTo(let v): return ", '>= \(v)'"
        case .lower(let v): return ", '< \(v)'"
        case .lowerOrEqualTo(let v): return ", '<= \(v)'"
        case .optimistic(let v): return ", '~> \(v)'"
        case .git(let git): return git.description
        case .none: return ""
        }
    }
}

class RNCocoapodsHelper {
    let podFilePath: String
    
    init(podFilePath: String) {
        self.podFilePath = podFilePath
    }
    
    class func isUsingCocoapodsProject(projectDir: String) -> Bool {
        return FileManager.default.fileExists(atPath: "\(projectDir)/Podfile")
    }
    
    func addDependecy(repoName: String,
                      target: String,
                      version: RepoVersionControl = .none,
                      tag: String? = nil,
                      branch: String? = nil) throws {
        let fileURL = URL(fileURLWithPath: podFilePath)
        var Podfile = try String(contentsOf: URL(fileURLWithPath: podFilePath)).components(separatedBy: .newlines)
        let start = Podfile.firstIndex { $0.contains("\(target)") }
        // 按照Target查找
        guard let startIndex = start else {
            return
        }
        Podfile.insert("  pod '\(repoName)\(version.description)", at: startIndex+1)
        try Podfile.joined(separator: "\n").write(to: fileURL, atomically: true, encoding: .utf8)
    }
}
