//
//  DaiPortal.h
//  DaiPortalV2
//
//  Created by 啟倫 陳 on 2014/11/24.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import <Foundation/Foundation.h>

//為了統一傳進跟回傳的東西, 所以用一個固定的格式來規範

@interface DaiPortalPackage : NSObject

//空的包包, 什麼都沒有
+ (DaiPortalPackage *)empty;

//只有一個物件
+ (DaiPortalPackage *)item:(id)anItem;

//很多的物件
+ (DaiPortalPackage *)items:(id)anItem, ...NS_REQUIRES_NIL_TERMINATION;

@end

@interface DaiPortal : NSObject

//分別是該傳送門的識別名稱跟所依附的物件
@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, weak) id dependObject;

@end

//建立用來接收資料的部分, 收到觸發時會運行 portalAction 的內容
@interface DaiPortal (Reciver)

- (void)open:(void (^)())portalAction;
- (void)feedback:(DaiPortalPackage *(^)())portalAction;

@end

//用來傳送資料的部分, 負責觸發已建立的傳送門
@interface DaiPortal (Sender)

//send 為傳一個以上的東西過去, poke 則為純粹的觸發
- (void)send:(DaiPortalPackage *)package;
- (void)poke;

//帶上 result 的話可以收到回傳的訊息
- (void)send:(DaiPortalPackage *)package result:(void (^)())result;
- (void)result:(void (^)())result;

@end
