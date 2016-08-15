//
//  FNDebugSettingViewController.h
//  FNMarket
//
//  Created by HG on 15/7/28.
//  Copyright (c) 2015年 cn.com.feiniu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^saveSuccessBlock)();
typedef void(^saveFailureBlock)();

@interface FNDebugSettingViewController : UIViewController
@property (nonatomic,copy) saveSuccessBlock saveSuccessBlock;
@property (nonatomic,copy) saveFailureBlock saveFailureBlock;

- (void)saveEviromentChnageSuccess:(saveSuccessBlock)success failure:(saveFailureBlock)failure;

@end
