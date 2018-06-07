//
//  main.swift
//  ProjectHelper
//
//  Created by Jiang,Zhenhua on 2018/6/6.
//  Copyright © 2018年 Jiang,Zhenhua. All rights reserved.
//

import Foundation

do {
    if ProcessInfo.processInfo.arguments.count > 1 {
        let module = try RNSubmoduleHelper(rootPath: ProcessInfo.processInfo.arguments[1])
        try module.cloneSubmodule()
    }
} catch(let e) {
    print(e.localizedDescription)
}

// RunLoop.main.run()
