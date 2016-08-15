//
//  FNMenuLabel.h
//  FNMarket
//
//  Created by FNNishipu on 11/9/15.
//  Copyright © 2015 cn.com.feiniu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FNMenuLabel : UILabel

@property (nonatomic, strong, readonly) UILongPressGestureRecognizer *longPressGestureRecognizer;
@property (nonatomic, copy) void(^CopiedText)(NSString *text);
@property (nonatomic, copy) CGRect(^TargetRect)(void);

@end
