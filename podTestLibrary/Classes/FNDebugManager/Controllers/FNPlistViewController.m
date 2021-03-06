//
//  FNPlistViewController.m
//  FNMerchant
//
//  Created by JR on 16/8/5.
//  Copyright © 2016年 FeiNiu. All rights reserved.
//

#import "FNPlistViewController.h"

@interface FNPlistViewController ()
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIScrollView *scrollView;
@end

@implementation FNPlistViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (UILabel *) label {
    if (!_label) {
        CGRect rect = self.view.bounds;
        _label = [[UILabel alloc]initWithFrame:rect];
        _label.textColor = [UIColor blackColor];
        _label.font = [UIFont systemFontOfSize:14];
        _label.numberOfLines = 0;
    }
    return _label;
}

- (UIScrollView *) scrollView {
    if (!_scrollView) {
        CGRect rect = self.view.bounds;
        _scrollView = [[UIScrollView alloc] initWithFrame:rect];
    }
    return _scrollView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setSourcePath:(NSString *) sourcePath {
//    [self.view addSubview:self.label];
    NSString *text = @"";
    NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:sourcePath];
    if ([NSJSONSerialization isValidJSONObject:dictionary]) {
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:&error];
        text =[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    CGRect rect = self.view.bounds;
    CGSize size =  [text boundingRectWithSize:CGSizeMake(rect.size.width, 200000)
                                      options:NSStringDrawingUsesLineFragmentOrigin
                                   attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]} context:nil].size;;
    _label.frame = CGRectMake(0, 64, size.width, size.height);
    self.label.text = text;
    
    if (size.height < rect.size.height) {
        size.height = rect.size.height + 1;
    }
    [self.scrollView setContentSize:size];
    [self.scrollView addSubview:self.label];
    [self.view addSubview:self.scrollView];
    
}

@end