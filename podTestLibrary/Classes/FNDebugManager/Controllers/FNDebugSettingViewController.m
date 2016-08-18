//
//  FNDebugSettingViewController.m
//  FNMarket
//
//  Created by HG on 15/7/28.
//  Copyright (c) 2015年 cn.com.feiniu. All rights reserved.
//

#import "FNDebugSettingViewController.h"
#import "UIColor+Hex.h"
#import "UILabel+Delay.h"
#import "FNMenuLabel.h"


#define ActivityWidth 50
#define ActivityHeight 50

@interface FNDebugSettingViewController () <UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *settingButton;
@property (weak, nonatomic) IBOutlet FNMenuLabel *cidLabel;
@property (weak, nonatomic) IBOutlet FNMenuLabel *diviceTokenLabel;

@property (nonatomic, copy)   NSString *cid;
@property (nonatomic, copy)   NSString *deviceToken;
@property (nonatomic, strong) UIActivityIndicatorView *activity;
@property (nonatomic, strong) NSArray *titleArray;
@property (nonatomic, assign) NSInteger currentIndexPath;
@property (nonatomic, assign) NSInteger oldIndexPath;


@end

@implementation FNDebugSettingViewController

- (instancetype)initWithCid:(NSString *)cid deviceToken:(NSString *)deviceToken {
    if (self = [super init]) {
        _cid = cid;
        _deviceToken = deviceToken;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"环境切换";
    self.titleArray = @[@"Dev",@"Beta",@"Preview",@"Online",];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"titleCell"];
    self.saveSuccessBlock = [FNDebugManager shareManager].saveSuccessBlock;
    self.saveFailureBlock = [FNDebugManager shareManager].saveFailureBlock;
    [self configUI];
}


- (void)configUI {
    [self.settingButton addTarget:self action:@selector(saveEnviermentChangeAndLogout) forControlEvents:UIControlEventTouchUpInside];
    
    
    if (_cid) {
        self.cidLabel.text = _cid;
    } else {
    NSString *cid = [[NSUserDefaults standardUserDefaults] valueForKey:@"getuiClientID"];
    self.cidLabel.text = (cid != nil) ? cid :@" ";
    }
    
    if (_deviceToken) {
        self.diviceTokenLabel.text= _deviceToken;
    } else {
        NSString *deviceToken = [[NSUserDefaults standardUserDefaults] valueForKey:@"deviceTokenID"];
        self.diviceTokenLabel.text = (deviceToken != nil) ? deviceToken :@" ";
    }
   
    [self.view addSubview:self.activity];
    
    self.oldIndexPath = [[FNDebugManager shareManager] domainType] - 1;
    self.currentIndexPath = self.oldIndexPath;

}


#pragma mark- UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.titleArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"titleCell" forIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryNone;

    if (indexPath.row == self.currentIndexPath) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    cell.textLabel.text = self.titleArray[indexPath.row];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.currentIndexPath = indexPath.row;
    
    [self.tableView reloadData];
}

- (void)backButtonClicked:(UIButton *)sender{
    [self.navigationController popToRootViewControllerAnimated:NO];
}


- (void)saveEnviermentChangeAndLogout{

    [self startActivity];
    [FNDebugManager changeEnvironment:self.currentIndexPath + 1];
    // 环境变更后立即去请求一份新的对应环境的API
    WS(weakSelf)
    [FNDebugManager requestAPIsResult:^(BOOL success) {
        if (success) {
            [UILabel showText:@"设置成功" delay:1.0];
            [[FNDebugManager shareManager] setDomainType:self.currentIndexPath + 1];
            [weakSelf.navigationController popToRootViewControllerAnimated:NO];
            if (weakSelf.saveSuccessBlock) {
                weakSelf.saveSuccessBlock();
            }
        } else {
            [UILabel showText:@"网络请求失败,请检查网络" delay:1.0];
            [FNDebugManager changeEnvironment:[FNDebugManager shareManager].domainType];
            if (weakSelf.saveFailureBlock) {
                weakSelf.saveFailureBlock();
            }
        }
        [weakSelf stopActivity];
    }];
  
}

- (void)startActivity {
    [self.activity startAnimating];
}

- (void)stopActivity {
    [self.activity stopAnimating];
}

- (UIActivityIndicatorView *)activity {
    if (!_activity) {
        _activity = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-ActivityWidth)/2, (SCREEN_HEIGHT-ActivityHeight)/2, ActivityWidth, ActivityHeight)];
        _activity.color = [UIColor darkGrayColor];
    }
    return _activity;
}




@end
