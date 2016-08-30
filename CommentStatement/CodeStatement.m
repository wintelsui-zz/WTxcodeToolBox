//
//  CodeStatement.m
//  WTToolBox
//
//  Created by 隋文涛 on 16/8/30.
//  Copyright © 2016年 wintelsui. All rights reserved.
//

#import "CodeStatement.h"

@implementation CodeStatement
+ (void)statementCommand:(XCSourceEditorCommandInvocation *)invocation{
    for (XCSourceTextRange *range in invocation.buffer.selections) {
        NSInteger startLine = range.start.line;
        NSInteger startColumn = range.start.column;
        NSInteger endLine = range.end.line;
        NSInteger endColumn = range.end.column;
        
        BOOL isAdd = NO;
        for (NSInteger index = startLine; index <= endLine ;index ++){
            NSString *line = [self deleteFirstSpace:invocation.buffer.lines[index]];
            //去掉了顶头的所有空格
            
            if (line == nil || line.length == 0 || ![line hasPrefix:@"//"]) {
                isAdd = YES;
                break;
            }
        }
        
        for (NSInteger index = startLine; index <= endLine ;index ++){
            NSString *line = invocation.buffer.lines[index];
            if (line == nil) {
                line = @"";
            }
            NSMutableString *stringNew = [[NSMutableString alloc] initWithString:line];
            if (isAdd) {
                //添加注释
                [stringNew insertString:@"//" atIndex:0];
            }else{
                //删除注释
                NSRange range = [stringNew rangeOfString:@"//"];
                [stringNew replaceCharactersInRange:range withString:@""];
            }
            [invocation.buffer.lines replaceObjectAtIndex:index withObject:stringNew];
        }
    }
}

+ (void)documentAdd:(XCSourceEditorCommandInvocation *)invocation{
    NSMutableString *stringDuel = [[NSMutableString alloc] init];
    NSInteger insertLine = -1;
    
    for (XCSourceTextRange *range in invocation.buffer.selections) {
        
        NSInteger startLine = range.start.line;
        NSInteger startColumn = range.start.column;
        NSInteger endLine = range.end.line;
        NSInteger endColumn = range.end.column;
        
        
        NSInteger linecount = [invocation.buffer.lines count];
        
        BOOL valid = NO;
        BOOL needUp = YES;//需要向上检索
        for (NSInteger index = startLine; index < linecount ;index ++){
            NSString *line = [self deleteFirstSpace:invocation.buffer.lines[index]];
            if (line != nil && line.length > 0 && ![line isEqualToString:@"\n"]) {
                if ([line rangeOfString:@"{"].length > 0 || [line rangeOfString:@";"].length > 0) {
                    //方法名称结束
                    valid = YES;
                }
                if (stringDuel.length == 0) {
                    [stringDuel appendString:line];
                }else{
                    [stringDuel appendFormat:@" %@",line];
                }
                
                if (needUp) {
                    if ([line hasPrefix:@"-"] || [line hasPrefix:@"+"]) {
                        //方法的开始
                        needUp = NO;
                        insertLine = index;
                    }
                }
                
                if (valid) {
                    //已经检测到结尾
                    break;
                }
            }
        }
        
        if (!valid) {
            return;
        }
        if (needUp){
            //没有找到方法的开始位置
            if (startLine > 0) {
                for (NSInteger index = startLine - 1 ; index > 0 ;index --){
                    NSString *line = [self deleteFirstSpace:invocation.buffer.lines[index]];
                    if (line != nil && line.length > 0) {
                        if ([line rangeOfString:@"{"].length > 0 || [line rangeOfString:@";"].length > 0) {
                            //方法名称结束
                            valid = NO;
                            break;
                        }
                        
                        if (stringDuel.length == 0) {
                            [stringDuel insertString:line atIndex:0];
                        }else{
                            [stringDuel insertString:[NSString stringWithFormat:@"%@ ",line] atIndex:0];
                        }
                        if ([line hasPrefix:@"-"] || [line hasPrefix:@"+"]) {
                            //方法的开始
                            needUp = NO;
                            insertLine = index;
                            break;
                        }
                    }
                }
            }else{
                return;
            }
        }
        
        if (needUp || !valid) {
            return;
        }
        
        
    }
    
    NSLog(@"stringDuel:%@",stringDuel);
    
    //    NSArray<NSString *> *lines = [replace componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    // update buffer
    
    // [invocation.buffer.lines replaceObjectsInRange:NSMakeRange(insertLine, 0)
    //withObjectsFromArray:lines];
    
    NSMutableArray *insertStrings = [[NSMutableArray alloc] init];
    [insertStrings addObject:@"/**\n"];
    [insertStrings addObject:@" *  @brief  <#brief#>\n"];
    [insertStrings addObject:@" *\n"];
    
    BOOL returnNA = YES;
    
    NSArray *cut = [stringDuel componentsSeparatedByString:@":"];
    NSInteger cutCount = [cut count];
    if (cut != nil && cutCount > 0) {
        NSString *stringReturn = [cut firstObject];
        {
            NSArray *array_return = [self regularFinder:@"\\(.*\\)" string:stringReturn];
            if ([array_return count]) {
                for (id XX in array_return) {
                    NSRange resultRange = [XX rangeAtIndex:0];
                    NSString *result = [stringReturn substringWithRange:resultRange];
                    if ([result rangeOfString:@"void"].length > 0) {
                        returnNA = YES;
                    }
                    break;
                }
            }
        }
        
        BOOL parameter = NO;
        NSMutableArray *parameters = [[NSMutableArray alloc] init];
        NSInteger lengthMax = 0;
        for (int i = 1; i < cutCount; i++) {
            NSString *stringParameter = [cut objectAtIndex:i];
            NSRange range = [stringParameter rangeOfString:@")"];
            if (range.length > 0) {
                NSInteger start = -1;
                NSInteger end = -1;
                for (NSInteger j = range.location + 1; j < stringParameter.length; j++) {
                    char sub = [stringParameter characterAtIndex:j];
                    if (sub == ' ') {
                        if (start == -1) {
                            
                        }else{
                            end = j;
                            break;
                        }
                    }else{
                        if (start == -1) {
                            start = j;
                        }
                    }
                }
                if (start != -1 && end != -1) {
                    range.location = start;
                    range.length = end - start;
                    NSString *parameterName = [stringParameter substringWithRange:range];
                    if (parameterName != nil && parameterName.length > 0) {
                        if (range.length >= lengthMax) {
                            lengthMax = range.length;
                        }
                        [parameters addObject:parameterName];
                    }
                }
            }
        }
        
        NSInteger len = @" *  @param ".length + lengthMax + 1;
        for (NSInteger index = 0; index < [parameters count]; index ++) {
            NSString *parameterName = [parameters objectAtIndex:index];
            NSMutableString *strtup = [[NSMutableString alloc] init];
            [strtup appendFormat:@" *  @param %@ ",parameterName];
            while (strtup.length < len) {
                [strtup appendString:@" "];
            }
            
            [strtup appendFormat:@"<#%@#>\n",parameterName];
            [insertStrings addObject:strtup];
            parameter = YES;
        }
        
        if (parameter) {
            [insertStrings addObject:@" *\n"];
        }
    }
    if (returnNA) {
        if (1){
            [insertStrings addObject:@" *  @return N/A\n"];
        }
    }else{
        [insertStrings addObject:@" *  @return <#return#>\n"];
    }
    [insertStrings addObject:@" */\n"];
    
    for (int i = 0 ; i < [insertStrings count]; i++){
        NSString *ins = [insertStrings objectAtIndex:i];
        [invocation.buffer.lines insertObject:ins atIndex:insertLine + i];
    }
}

+ (NSString *)deleteFirstSpace:(NSString *)oldString{
    if (oldString == nil || oldString.length == 0) {
        return @"";
    }
    NSString *newString = oldString;
    while (newString.length > 0) {
        if ([newString hasPrefix:@" "]) {
            if (newString.length > 1) {
                newString = [newString substringFromIndex:1];
            }else{
                newString = @"";
            }
        }else{
            break;
        }
    }
    return newString;
}

+ (NSArray *)regularFinder:(NSString *)regular string:(NSString *)str{
    NSError *error_finder;
    //这是检测正则表达式
    NSRegularExpression *regex_finder = [NSRegularExpression regularExpressionWithPattern:regular options:0 error:&error_finder];
    if (regex_finder != nil) {
        NSArray *array_finder = [regex_finder matchesInString:str options:0 range:NSMakeRange(0, [str length])];
        return array_finder;
    }
    return nil;
}

@end
