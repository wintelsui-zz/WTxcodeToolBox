//
//  CodeStatement.h
//  WTToolBox
//
//  Created by 隋文涛 on 16/8/30.
//  Copyright © 2016年 wintelsui. All rights reserved.
//

#import <XcodeKit/XcodeKit.h>

@interface CodeStatement : NSObject
+ (void)statementCommand:(XCSourceEditorCommandInvocation *)invocation;
+ (void)documentAdd:(XCSourceEditorCommandInvocation *)invocation;
@end
