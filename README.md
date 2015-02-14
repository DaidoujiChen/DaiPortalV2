DaiPortalV2
===========

Portal is a idea for transfer objects from A place to B place.

DaidoujiChen

daidoujichen@gmail.com

總覽
===========
傳送門是一個突發奇想, 自己覺得有趣的概念, 目的是在 objects 之間, 互相的傳遞訊息.

支援
===========
- 只支援 ARC.

使用
===========
首先, 需要 `import` 的檔案只有一個, 在需要使用傳送門的地方

	#import "NSObject+DaiPortal.h"
	
就可以開始建立簡單的傳送裝置, 接下來, 定義一個名稱是 `daidouji` 的傳送門

	[self portal:@"daidouji"];
	
不過, 這個狀況下, 傳送門並還沒有被激活, 我們需要定義它的功能上為 `送出`, 或是 `接收`, 而後, 傳送門便會正常的開始工作.

接收
-
從接收開始說起, 當接收傳送門被建立以後, 他會一直接收並且處理別人丟過來的東西, 直到他依附的物件被摧毀,

	[[self portal:@"daidouji"] recv: ^{
        NSLog(@"hello");
    }];
    
可以在收到訊息的時候, 打印出 `hello` 來, 如果要傳遞參數進來, 只需要改為

	[[self portal:@"daidouji"] recv: ^(NSString *name) {
        NSLog(@"hello, %@", name);
    }];
    
就可以跟傳遞進來的參數說 `hello`, 然而, 有些時候, 我們處理完某些事情之後, 需要將處理完的結果丟還給原先的傳送門, 我把這種行為叫做 `respond`, 以上面的例子來說, 我們可以建立一個傳送門, 在說完 `hello` 之後, 返回原先的傳送門處理接下來的事情

    [[self portal:@"daidouji"] respond: ^DaiPortalPackage * {
        NSLog(@"hello");
        return DaiPortalPackageEmpty;
    }];
    
`DaiPortalPackage` 是專為傳送門定義的一種包裝, 會在後面的部分解釋, 這邊就先當作他可以把東西回傳回去就好, 所以也可以是

	[[self portal:@"daidouji"] respond: ^DaiPortalPackage *(NSString *name) {
        NSLog(@"hello, %@", name);
        return DaiPortalPackageItem(@"hello complete");
    }];
    
在接收的部分 `block` 並沒有限制傳入參數的數量, 因此, 可以根據需求, 調整這個部分.

當 `recv` 或是 `respond` 後面被冠上 `_warp` 結尾的時候 `block` 內的 code 會以非主線程執行, 比方

	 [[self portal:@"daidouji"] recv_warp: ^{
        NSLog(@"hello");
    }];
    
這個 `hello` 可以在不阻礙線程的情況下執行.

送出
-
有接收當然就必須要有送出, 與上面例子中相對應使用的傳送門為

	[[self portal:@"daidouji"] recv: ^{
        NSLog(@"hello");
    }];
    
    [[self portal:@"daidouji"] send];
    
當單觸發接收傳送門時, 可僅以 `send` 這個 `method` 達成, 至於要 `send` 參數過去的話, 可以使用下面的方法

	[[self portal:@"daidouji"] recv: ^(NSString *name) {
        NSLog(@"hello, %@", name);
    }];
    
    [[self portal:@"daidouji"] send:DaiPortalPackageItem(@"daidouji")];
    
需要知道接收傳送門已經做完事情了的話可以這樣

	[[self portal:@"daidouji"] respond: ^DaiPortalPackage * {
        NSLog(@"hello");
        return DaiPortalPackageEmpty;
    }];
    
    [[self portal:@"daidouji"] completion: ^{
        NSLog(@"recv portal completion");
    }];
    
需要做完之後回傳值可以這樣

	[[self portal:@"daidouji"] respond: ^DaiPortalPackage * (NSNumber *number1, NSNumber *number2) {
        int sum = [number1 intValue] + [number2 intValue];
        return DaiPortalPackageItem(@(sum));
    }];
    
    [[self portal:@"daidouji"] send:DaiPortalPackageItems(@(1), @(2)) completion: ^(NSNumber *sum) {
        NSLog(@"sum is : %@", sum);
    }];
    
同樣的在 `completion` 後面加上 `_warp` 的時候, 這裡面的 code 會以非主線程運行.

包裝
-
這邊我定義了三種包裝的內容, 分別是

	DaiPortalPackageEmpty
	
什麼也沒有, 代表接收傳送門或是需要返回值的送出傳送門 `block` 內需要的參數為零個, 接下來是

	DaiPortalPackageItem(@"hello")
	
包裝一個參數, 可以適用於只有一個參數需要傳遞時, 最後

	DaiPortalPackageItems(@(1), @(2))
	
可以包裝一個以上的參數, 當然, 也可以傳遞像是 `nil` 一類的參數, 比如說

	DaiPortalPackageItem(nil)
	
或是

	DaiPortalPackageItems(@(1), nil)
	
優點
===========
這其中的過程用起來會好像是 `NSNotification`, 那為什麼不直接用 `NSNotification` 而要用 `DaiPortal` 做?

1. `DaiPortal` 會隨著物件的摧毀而釋放, 不需要像 `NSNotification` 寫 `add` 與 `remove`.
2. `DaiPortal` 從 `block` 清楚的定義該傳送門傳送的物件為何, 接收的物件為何, `NSNotification` 則是在收到之後才對其分別處理.
3. 當 `DaiPortal` 檢查到傳送與接收的參數數量不匹配時, 會 log 出錯誤的訊息, 幫助檢查傳遞的正確性.