//
//  FNDebugSettingViewController.h
//  FNMarket
//
//  Created by HG on 15/7/28.
//  Copyright (c) 2015年 cn.com.feiniu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FNDebugManager.h"



@interface FNDebugSettingViewController : UIViewController
@property (nonatomic,copy) saveSuccessBlock saveSuccessBlock;
@property (nonatomic,copy) saveFailureBlock saveFailureBlock;

/**
 *  初始化
 *
 *  @param cid         传入外部cid显示
 *  @param deviceToken 传入外部deviceToken显示
 *
 *  @return self
 */
- (instancetype)initWithCid:(NSString *)cid deviceToken:(NSString *)deviceToken;


@end
