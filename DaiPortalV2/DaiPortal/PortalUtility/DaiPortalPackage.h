//
//  DaiPortalPackage.h
//  DaiPortalV2
//
//  Created by 啟倫 陳 on 2015/2/10.
//  Copyright (c) 2015年 ChilunChen. All rights reserved.
//

//為了統一傳進跟回傳的東西, 所以用一個固定的格式來規範

#import <Foundation/Foundation.h>

@interface DaiPortalPackage : NSObject

@property (nonatomic, strong) id anyObject;

//空的包包, 什麼都沒有
+ (DaiPortalPackage *)empty;

//只有一個物件
+ (DaiPortalPackage *)item:(id)anItem;

//很多的物件
+ (DaiPortalPackage *)items:(id)firstItem, ...NS_REQUIRES_NIL_TERMINATION;

@end
