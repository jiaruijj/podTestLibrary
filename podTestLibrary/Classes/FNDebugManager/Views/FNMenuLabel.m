//
//  FNMenuLabel.m
//  FNMarket
//
//  Created by FNNishipu on 11/9/15.
//  Copyright © 2015 cn.com.feiniu. All rights reserved.
//

#import "FNMenuLabel.h"

@implementation FNMenuLabel

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib
{
    [self setup];
}

- (void)setup
{
    self.userInteractionEnabled = YES;
    _longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureRecognized:)];
    [self addGestureRecognizer:_longPressGestureRecognizer];
}

- (void)longPressGestureRecognized:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
        [self becomeFirstResponder];
        [[UIMenuController sharedMenuController] setTargetRect:_TargetRect ? _TargetRect() : self.bounds inView:self];
        [[UIMenuController sharedMenuController] setMenuVisible:YES animated:YES];
    }
}

#pragma mark - UIResponder
- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    return action == @selector(copy:);
}

- (void)copy:(id)sender
{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = self.text;
    !_CopiedText ?: _CopiedText(self.text);
}

@end

















