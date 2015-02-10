//
//  DaiPortal+Internal.m
//  DaiPortalV2
//
//  Created by 啟倫 陳 on 2015/2/11.
//  Copyright (c) 2015年 ChilunChen. All rights reserved.
//

#import "DaiPortal+Internal.h"

#import <objc/runtime.h>

#import "SFExecuteOnDeallocInternalObject.h"
#import "DaiPortalMessager.h"
#import "DaiPortalBlockAnalysis.h"
#import "DaiPortalPerformHelper.h"

@implementation DaiPortal (Internal)

@dynamic actionBlock, argumentsInBlock, returnTypeInBlock, resultPortalIdentifier, isDisposable, isWarp;

#pragma mark - internal objects

- (void)setActionBlock:(id)actionBlock {
    objc_setAssociatedObject(self, @selector(actionBlock), actionBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
    objc_setAssociatedObject(self, @selector(argumentsInBlock), @([DaiPortalBlockAnalysis argumentsInBlock:actionBlock] - 1), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, @selector(returnTypeInBlock), @([DaiPortalBlockAnalysis returnTypeInBlock:actionBlock]), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id)actionBlock {
    return objc_getAssociatedObject(self, _cmd);
}

- (NSUInteger)argumentsInBlock {
    NSNumber *argumentsInBlock = objc_getAssociatedObject(self, _cmd);
    return [argumentsInBlock unsignedIntegerValue];
}

- (DaiPortalBlockAnalysisReturnType)returnTypeInBlock {
    NSNumber *returnTypeInBlock = objc_getAssociatedObject(self, _cmd);
    return [returnTypeInBlock integerValue];
}

- (NSString *)resultPortalIdentifier {
    return [NSString stringWithFormat:@"%@_result", self.identifier];
}

- (BOOL)isDisposable {
    return ([self.identifier rangeOfString:@"_result"].location != NSNotFound);
}

- (void)setIsWarp:(BOOL)isWarp {
    objc_setAssociatedObject(self, @selector(isWarp), @(isWarp), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)isWarp {
    NSNumber *isWarp = objc_getAssociatedObject(self, _cmd);
    return [isWarp boolValue];
}

#pragma mark - internal method

//用來監測物件是否該被移除
- (void)deallocObserver {
    if (!objc_getAssociatedObject(self.dependObject, _cmd)) {
        SFExecuteOnDeallocInternalObject *internalObject = [[SFExecuteOnDeallocInternalObject alloc] initWithBlock: ^{
            [DaiPortalMessager destory:self.dependObject];
        }];
        objc_setAssociatedObject(self.dependObject, _cmd, internalObject, OBJC_ASSOCIATION_RETAIN);
    }
}

//把新的傳送門登記到倉庫中
- (void)signPortal:(id)block {
    [self deallocObserver];
    self.actionBlock = block;
    [DaiPortalMessager sign:self];
}

- (void)broadcastPackage:(DaiPortalPackage *)package {
    [DaiPortalMessager broadcastToIdentifier:self.identifier objects:package.anyObject fromSource:self.dependObject];
}

//控制接到的通知
- (void)handleRecvNotification:(NSNotification *)notification {
    //如果依附的對象已經被刪除, 這邊則直接將他從 list 移除
    if (!self.dependObject) {
        [DaiPortalMessager resign:self];
        return;
    }
    
    //要先看傳送過來的數量是不是跟要輸出的數量一致
    if (self.argumentsInBlock == [notification.object count]) {
        
        //根據 block 的類型又可以分為回傳 void 及 DaiPortalPackage 兩種
        switch (self.returnTypeInBlock) {
            case DaiPortalBlockAnalysisReturnTypeID:
            {
                [self handleReturnID:notification];
                break;
            }
                
            case DaiPortalBlockAnalysisReturnTypeVoid:
            {
                [self handleReturnVoid:notification];
                break;
            }
                
            case DaiPortalBlockAnalysisReturnTypeUnknow:
            {
                NSLog(@"應該沒有人會到這邊吧, O口O!");
                break;
            }
        }
    }
    else {
        NSLog(@"從 %@ 傳送往 %@, 識別為 <%@> 的參數數量不匹配.", notification.userInfo[@"source"], self.dependObject, self.identifier);
    }
}

- (void)disposableCheck {
    //免洗的傳送門用一次就丟掉
    if (self.isDisposable) {
        [DaiPortalMessager resign:self];
    }
}

#pragma mark - private

#pragma mark * handle portal result

- (void)handleReturnID:(NSNotification *)notification {
    if (self.isWarp) {
        __weak DaiPortal *weakSelf = self;
        [self warp: ^{
            DaiPortalPackage *result = [DaiPortalPerformHelper idPerformObjects:notification.object usingBlock:weakSelf.actionBlock];
            [weakSelf direct: ^{
                if (result && result.anyObject) {
                    [DaiPortalMessager broadcastToIdentifier:weakSelf.resultPortalIdentifier objects:result.anyObject fromSource:weakSelf.dependObject];
                }
                [weakSelf disposableCheck];
            }];
        }];
    }
    else {
        DaiPortalPackage *result = [DaiPortalPerformHelper idPerformObjects:notification.object usingBlock:self.actionBlock];
        if (result && result.anyObject) {
            [DaiPortalMessager broadcastToIdentifier:self.resultPortalIdentifier objects:result.anyObject fromSource:self.dependObject];
        }
        [self disposableCheck];
    }
}

- (void)handleReturnVoid:(NSNotification *)notification {
    if (self.isWarp) {
        __weak DaiPortal *weakSelf = self;
        [self warp: ^{
            [DaiPortalPerformHelper voidPerformObjects:notification.object usingBlock:weakSelf.actionBlock];
            [weakSelf direct: ^{
                [weakSelf disposableCheck];
            }];
        }];
    }
    else {
        [DaiPortalPerformHelper voidPerformObjects:notification.object usingBlock:self.actionBlock];
        [self disposableCheck];
    }
}

#pragma mark * callback

- (void)warp:(void (^)(void))block {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block);
}

- (void)direct:(void (^)(void))block {
    dispatch_async(dispatch_get_main_queue(), block);
}

@end
