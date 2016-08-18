//
//  FNDebugSettingViewController.m
//  FNMarket
//
//  Created by HG on 15/7/28.
//  Copyright (c) 2015年 cn.com.feiniu. All rights reserved.
//

#import "FNDebugSettingViewController.h"
#import "FNDebugManager.h"
#import "UIColor+Hex.h"
#import "UILabel+Delay.h"
#import "FNMenuLabel.h"



@interface FNDebugSettingViewController () <UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *settingButton;
@property (weak, nonatomic) IBOutlet FNMenuLabel *cidLabel;
@property (weak, nonatomic) IBOutlet FNMenuLabel *diviceTokenLabel;


@property (nonatomic, strong) NSArray *titleArray;
@property (nonatomic, assign) NSInteger currentIndexPath;
@property (nonatomic, assign) NSInteger oldIndexPath;
@property (nonatomic, strong) UILabel *clientIDLabel;


@end

@implementation FNDebugSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"环境切换";
    self.titleArray = @[@"Dev",@"Beta",@"Preview",@"Online",];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"titleCell"];
    [self configUI];
//    self.tableView.tableFooterView = [self footerView];
    
    
    
}


- (void)configUI {
    [self.settingButton addTarget:self action:@selector(saveEnviermentChangeAndLogout) forControlEvents:UIControlEventTouchUpInside];
    
    NSString *cid = [[NSUserDefaults standardUserDefaults] valueForKey:@"getuiClientID"];
    self.cidLabel.text = (cid != nil) ? cid :@" ";
    
    NSString *deviceToken = [[NSUserDefaults standardUserDefaults] valueForKey:@"deviceTokenID"];
    self.diviceTokenLabel.text = (deviceToken != nil) ? deviceToken :@" ";
    
    self.oldIndexPath = [[FNDebugManager shareManager] domainType] - 1;
    self.currentIndexPath = self.oldIndexPath;

}

- (UIView *)footerView{
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 200)];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(20, 30, SCREEN_WIDTH - 40, 40)];
    button.backgroundColor = [UIColor hexStringToColor:@"#db384c"];
    button.layer.cornerRadius = 4;
    button.layer.masksToBounds = YES;
    [button setTitle:@"保存设置" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(saveEnviermentChangeAndLogout) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:button];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 70, SCREEN_WIDTH, 60)];
    title.text = @"由于服务端不建议使用默认token\n,修改登出为网络请求登出，切换环境后保存设置才能生效";
    title.textColor = [UIColor lightGrayColor];
    title.font = [UIFont systemFontOfSize:14];
    title.textAlignment = NSTextAlignmentCenter;
    title.numberOfLines = 0;
    [footerView addSubview:title];
    
    [footerView addSubview:({
        UIView *clientIDView = [[UIView alloc] initWithFrame:CGRectMake(0, 140, SCREEN_WIDTH, 60)];
        
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 17)];
        title.text = @"clientID, 长按拷贝:\n";
        title.textColor = [UIColor lightGrayColor];
        title.textAlignment = NSTextAlignmentCenter;
        [clientIDView addSubview:title];
        
        FNMenuLabel *clientIDLabel = [[FNMenuLabel alloc] initWithFrame:CGRectMake(0, 30, SCREEN_WIDTH, 20)];
        NSString *deviceToken = [[NSUserDefaults standardUserDefaults] valueForKey:@"getuiClientID"];
        clientIDLabel.text = (deviceToken != nil) ? deviceToken :@" ";
        clientIDLabel.textAlignment = NSTextAlignmentCenter;
        clientIDLabel.adjustsFontSizeToFitWidth = YES;
        clientIDLabel.textColor = [UIColor lightGrayColor];
        [clientIDView addSubview:clientIDLabel];
        
        [clientIDView addGestureRecognizer:clientIDLabel.longPressGestureRecognizer];
        
        clientIDView;
    })];
    
    [footerView addSubview:({
        UIView *clientIDView = [[UIView alloc] initWithFrame:CGRectMake(0, 200, SCREEN_WIDTH, 90)];
        
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 17)];
        title.text = @"deviceToken, 长按拷贝:\n";
        title.textColor = [UIColor lightGrayColor];
        title.textAlignment = NSTextAlignmentCenter;
        [clientIDView addSubview:title];
        
        FNMenuLabel *clientIDLabel = [[FNMenuLabel alloc] initWithFrame:CGRectMake(0, 30, SCREEN_WIDTH, 50)];
        NSString *deviceToken = [[NSUserDefaults standardUserDefaults] valueForKey:@"deviceTokenID"];
        clientIDLabel.text = (deviceToken != nil) ? deviceToken :@" ";
        clientIDLabel.textAlignment = NSTextAlignmentCenter;
        clientIDLabel.numberOfLines = 0;
        clientIDLabel.adjustsFontSizeToFitWidth = YES;
        clientIDLabel.textColor = [UIColor lightGrayColor];
        [clientIDView addSubview:clientIDLabel];
        
        [clientIDView addGestureRecognizer:clientIDLabel.longPressGestureRecognizer];
        
        clientIDView;
    })];

    
    return footerView;
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


- (void)saveEviromentChnageSuccess:(saveSuccessBlock)success failure:(saveFailureBlock)failure
{
    if (success) {
        self.saveSuccessBlock = success;
    }
    if (failure) {
        self.saveFailureBlock = failure;
    }
    [self saveFailureBlock];
}

- (void)saveEnviermentChangeAndLogout{

    
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
    }];
  
}






@end
