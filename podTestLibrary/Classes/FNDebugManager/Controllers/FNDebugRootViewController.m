//
//  FNDebugRootViewController.m
//  FNMerchant
//
//  Created by JR on 16/8/5.
//  Copyright © 2016年 FeiNiu. All rights reserved.
//

#import "FNDebugRootViewController.h"
#import "FNDebugManager.h"
#import "FNDebugSettingViewController.h"
#import "NSBundle+MyLibrary.h"

@interface FNDebugRootViewController ()
@property (nonatomic, strong) NSMutableArray *data;
@end

@implementation FNDebugRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Debug";
    self.data = [NSMutableArray array];
    [self configData];
    self.tableView.tableFooterView = [UIView new];
    [self.tableView reloadData];
}


- (void) configData {
    NSBundle *manager = [NSBundle myLibraryBundle];
    NSString *documentsDirectory = [manager pathForResource:@"Debug.bundle/debug" ofType:@"plist"];
    self.data = [[NSMutableArray alloc] initWithContentsOfFile:documentsDirectory];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.data count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *dequeueReusableCellWithIdentifier = @"dequeueReusableCellWithIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:dequeueReusableCellWithIdentifier];
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:dequeueReusableCellWithIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    cell.textLabel.text = self.data[indexPath.row][@"name"];
    cell.detailTextLabel.text = self.data[indexPath.row][@"author"];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 45;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *classString = self.data[indexPath.row][@"class"];
    Class newClass = NSClassFromString(classString);
        UIViewController *controller = [[newClass alloc] init];
    if ([controller isKindOfClass:[FNDebugSettingViewController class]]) {
        controller = [[FNDebugSettingViewController alloc] initWithCid:[FNDebugManager shareManager].cid deviceToken:[FNDebugManager shareManager].deviceToken];
    }

    controller.title = self.data[indexPath.row][@"name"];

    if (controller) {
        [self.navigationController pushViewController:controller animated:YES];
    }
}
@end
