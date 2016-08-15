//
//  FNPictureViewController.m
//  FNMerchant
//
//  Created by JR on 16/8/5.
//  Copyright © 2016年 FeiNiu. All rights reserved.
//

#import "FNPictureViewController.h"

@interface FNPictureViewController()
@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation FNPictureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (UIImageView *) imageView {
    if (!_imageView) {
        CGRect rect = self.view.bounds;
        _imageView = [[UIImageView alloc] initWithFrame:rect];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _imageView;
}

- (void) setSourcePath:(NSString *) sourcePath {
    self.imageView.image = [UIImage imageWithContentsOfFile:sourcePath];
    [self.view addSubview:self.imageView];
    self.imageView.center = self.view.center;
}


@end
