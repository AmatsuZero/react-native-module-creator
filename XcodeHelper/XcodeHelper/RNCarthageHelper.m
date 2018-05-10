//
//  RNCarthageHelper.m
//  XcodeHelper
//
//  Created by modao on 2018/5/10.
//  Copyright © 2018年 Daubert. All rights reserved.
//

#import "RNCarthageHelper.h"

@implementation RNCarthageHelper
{
    NSString* filePath;
    NSArray<NSString*>* repoNames;
    NSArray<NSString*>* paths;
}

- (instancetype)initWithName:(NSArray<NSString*>*)repos atPath:(NSString *)path {
    if (self = [super init]) {
        NSString* cartfile = [path stringByAppendingPathComponent:@"Cartfile"];
        if (![[NSFileManager defaultManager] fileExistsAtPath:cartfile]) {
            NSMutableString* file = [NSMutableString string];
            [repos enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSString* line = [NSString stringWithFormat:@"github %@\n", obj];
                [file appendString:line];
            }];
            NSError* error = nil;
            [file writeToFile:cartfile
                   atomically:YES
                     encoding:NSUTF8StringEncoding
                        error:&error];
            if (error) return nil;
            filePath = cartfile;
            repoNames = repos;
        }
    }
    return self;
}

- (BOOL) intall {
    NSTask* task = [[NSTask alloc] init];
    task.arguments = @[@"carthage", @"bootstrap"];
    task.currentDirectoryPath = filePath;
    NSError* error = nil;
    [task launchAndReturnError:&error];
    return error == nil;
}

- (NSArray<NSString *> *)frameworkPaths {
    if (!paths) {
        NSString* root = [filePath stringByDeletingLastPathComponent];
        root = [root stringByAppendingPathComponent:@"Carthage/Build/iOS"];
        NSMutableArray<NSString*>* array = [NSMutableArray array];
        [repoNames enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString* item = [[root stringByAppendingString: obj] stringByAppendingPathExtension:@"framework"];
            [array addObject:item];
        }];
        paths = [array copy];
    }
    return paths;
}

@end
