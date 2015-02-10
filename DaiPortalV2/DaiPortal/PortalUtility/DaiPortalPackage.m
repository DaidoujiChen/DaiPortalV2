//
//  DaiPortalPackage.m
//  DaiPortalV2
//
//  Created by 啟倫 陳 on 2015/2/10.
//  Copyright (c) 2015年 ChilunChen. All rights reserved.
//

#import "DaiPortalPackage.h"

@implementation DaiPortalPackage

+ (DaiPortalPackage *)empty {
    DaiPortalPackage *newResult = [DaiPortalPackage new];
    newResult.anyObject = nil;
    return newResult;
}

+ (DaiPortalPackage *)item:(id)anObject {
    DaiPortalPackage *newResult = [DaiPortalPackage new];
    newResult.anyObject = @[anObject];
    return newResult;
}

+ (DaiPortalPackage *)items:(id)firstItem, ...NS_REQUIRES_NIL_TERMINATION {
    NSMutableArray *objects = [NSMutableArray array];
    if (firstItem) {
        va_list list;
        id listObject = firstItem;
        va_start(list, firstItem);
        do {
            if (listObject) {
                [objects addObject:listObject];
            }
            listObject = va_arg(list, id);
        }
        while (listObject != nil);
        va_end(list);
    }
    DaiPortalPackage *newResult = [DaiPortalPackage new];
    newResult.anyObject = objects;
    return newResult;
}

@end
