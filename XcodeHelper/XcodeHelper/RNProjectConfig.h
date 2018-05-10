//
//  RNProjectConfig.h
//  XcodeHelper
//
//  Created by modao on 2018/5/10.
//  Copyright © 2018年 Daubert. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XcodeEditor/XcodeEditor.h>

@interface RNProjectConfig : NSObject

@property(nonatomic, readonly, nullable)XCGroup* group;

- (_Nullable instancetype) initWithJSON:(NSString * _Nonnull) jsonStr;


- (void) buildAndLinkCarthgeFiles:(NSArray<NSString*>* _Nonnull) files;

@end
