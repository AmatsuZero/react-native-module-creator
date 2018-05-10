//
//  RNCarthageHelper.h
//  XcodeHelper
//
//  Created by modao on 2018/5/10.
//  Copyright © 2018年 Daubert. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RNCarthageHelper : NSObject

/**
 动态库地址
 */
@property(nonatomic, readonly, nullable)NSArray<NSString*>* frameworkPaths;

/**
 初始化Helper对象

 @param repos repo名称（作者+项目名）
 @param path iOS项目所在的路径
 @return Helper对象
 */
- (_Nullable instancetype)initWithName:(NSArray<NSString*>* _Nonnull)repos atPath:(NSString* _Nonnull)path;

/**
 通过Carthage安装依赖

 @return 安装是否成功
 */
- (BOOL) install;

@end
