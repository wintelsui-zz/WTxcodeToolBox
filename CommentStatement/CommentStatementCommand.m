//
//  SourceEditorCommand.m
//  CommentStatement
//
//  Created by wintelsui on 16/8/30.
//  Copyright © 2016年 wintelsui. All rights reserved.
//

#import "CommentStatementCommand.h"

#import "CodeStatement.h"

@implementation CommentStatementCommand

- (void)performCommandWithInvocation:(XCSourceEditorCommandInvocation *)invocation completionHandler:(void (^)(NSError * _Nullable nilOrError))completionHandler
{
    //com.wintel.WTToolBox.WTImageName.SourceEditorCommand
    //XCSourceEditorCommandDefinitions
    //$(PRODUCT_BUNDLE_IDENTIFIER).CommentStatementCommand
    NSString *identifier = invocation.commandIdentifier;
    
    if ([identifier hasSuffix:@"CommentStatement"]) {
        //注释代码
        [CodeStatement statementCommand:invocation];
    }else if ([identifier hasSuffix:@"DocumentAdd"]) {
        //添加注释
        [CodeStatement documentAdd:invocation];
    }
    completionHandler(nil);
}
@end
