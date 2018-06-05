//
//  main.m
//  XcodeHelper
//
//  Created by modao on 2018/5/9.
//  Copyright © 2018年 Daubert. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XcodeEditor/XcodeEditor.h>
#import "RNProjectConfig.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSString* json = [[NSProcessInfo processInfo].arguments firstObject];
        if (!json) {
            return -10080;
        }
       __unused RNProjectConfig* config = [[RNProjectConfig alloc] initWithJSON:json];
    }
    return 0;
}
