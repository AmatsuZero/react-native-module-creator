//
//  RNProjectConfig.m
//  XcodeHelper
//
//  Created by modao on 2018/5/10.
//  Copyright © 2018年 Daubert. All rights reserved.
//

#import "RNProjectConfig.h"
#import "RNCarthageHelper.h"

@interface RNProjectConfig()

- (void) addClass:(NSString* _Nonnull)name atPath:(NSString* _Nonnull)path;
- (void) addHeaderFile: (NSString* _Nonnull)name atPath:(NSString* _Nonnull)path;
- (void) addSwiftFile: (NSString* _Nonnull)name atPath:(NSString* _Nonnull)path;
- (void) addOCFile: (NSString* _Nonnull)name atPath:(NSString* _Nonnull)path;
- (void) addFramework:(NSString * _Nonnull) name;

@end

@implementation RNProjectConfig
{
    NSString* _Nullable name;
    NSString* _Nullable path;
    NSString* _Nullable exampleFolder;
    NSString* _Nullable templateFolder;
    NSString* _Nullable destionationPath;
    XCProject* _Nullable project;
    NSArray<NSString*>* _Nullable carthageRepos;
}

- (instancetype)initWithJSON:(NSString *)jsonStr {
    if (self = [super init]) {
        NSData* data = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
        NSError* error = nil;
        NSDictionary<NSString*, id>* dict = [NSJSONSerialization JSONObjectWithData:data
                                                                                   options:NSJSONReadingMutableContainers
                                                                                     error:&error];
        if (error) return nil;
        name = dict[@"name"];
        path = dict[@"path"];
        exampleFolder = dict[@"example"];
        templateFolder = dict[@"template"];
        carthageRepos = dict[@"carthage"];
        project = [[XCProject alloc] initWithFilePath: [templateFolder stringByAppendingPathComponent:@"TemplateLibrary.xcodeproj"]];
        _group = [project groupWithPathFromRoot: name];
    }
    return self;
}

- (void)buildAndLinkCarthgeFiles:(NSArray<NSString*>* _Nonnull) files {
    RNCarthageHelper* helper = [[RNCarthageHelper alloc] initWithName:carthageRepos atPath:templateFolder];
    if ([helper install]) {
//        __weak typeof(self) weakSelf = self;
//        [helper.frameworkPaths enumerateObjectsUsingBlock:^(NSString * _Nonnull path, NSUInteger idx, BOOL * _Nonnull stop) {
//
//        }];
    }
}


#pragma mark - Project Files Manager
- (void)addClass:(NSString *)name atPath:(NSString *)path {
    XCClassDefinition* definition = [[XCClassDefinition alloc] initWithName:name language:ObjectiveC];
    // read header file
    NSError* error = nil;
    NSURL* folderURL = [NSURL fileURLWithPath:path];
    NSURL* headerURL = [folderURL URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.h",name]];
    NSString* header = [NSString stringWithContentsOfURL:headerURL
                                                encoding:NSUTF8StringEncoding
                                                   error:&error];
    if (error) @throw error;
    [definition setHeader:header];
    NSURL* implURL = [folderURL URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.m",name]];
    NSString* impl = [NSString stringWithContentsOfURL:implURL encoding:NSUTF8StringEncoding error:&error];
    if (error) @throw error;
    [definition setSource:impl];
    [self.group addClass:definition];
    [project save];
}

- (void)addHeaderFile:(NSString *)name atPath:(NSString *)path {
    NSError* error = nil;
    NSString* content = [NSString stringWithContentsOfFile:path
                                                  encoding:NSUTF8StringEncoding
                                                     error:&error];
    if (error) @throw error;
    XCSourceFileDefinition* headerFile = [[XCSourceFileDefinition alloc] initWithName:[NSString stringWithFormat:@"%@.h", name]
                                                                                 text:content
                                                                                 type:SourceCodeHeader];
    [self.group addSourceFile:headerFile];
    [project save];
}

- (void)addSwiftFile:(NSString *)name atPath:(NSString *)path {
    NSError* error = nil;
    NSString* content = [NSString stringWithContentsOfFile:path
                                                  encoding:NSUTF8StringEncoding
                                                     error:&error];
    if (error) @throw error;
    XCSourceFileDefinition* file = [[XCSourceFileDefinition alloc] initWithName:[NSString stringWithFormat:@"%@.m", name]
                                                                           text:content
                                                                           type:SourceCodeSwift];
    [self.group addSourceFile:file];
    // 检查是否包含Header File，没有，则创建

    [project save];
}

- (void)addOCFile:(NSString *)name atPath:(NSString *)path {
    NSError* error = nil;
    NSString* content = [NSString stringWithContentsOfFile:path
                                                  encoding:NSUTF8StringEncoding
                                                     error:&error];
    if (error) @throw error;
    XCSourceFileDefinition* file = [[XCSourceFileDefinition alloc] initWithName:[NSString stringWithFormat:@"%@.m", name]
                                                                           text:content
                                                                           type:SourceCodeObjC];
    [self.group addSourceFile:file];
    [project save];
}

- (void)addFramework:(NSString *)name {
    XCSourceFile* libSrcFile = [project fileWithName:name];
    XCTarget* target = [project targetWithName:@"TemplateLibrary"];
    [target addMember:libSrcFile];
    for (NSString* configName in target.configurations) {
        XCProjectBuildConfig* configuration = [target configurationWithName:configName];
        NSMutableArray* headerPaths = [NSMutableArray array];
        [headerPaths addObject:@"$(inherited)"];
        [headerPaths addObject:[NSString stringWithFormat:@"$(PROJECT_DIR)/%@", name]];
        [configuration addOrReplaceSetting:headerPaths forKey:@"LIBRARY_SEARCH_PATHS"];
    }
}

@end
