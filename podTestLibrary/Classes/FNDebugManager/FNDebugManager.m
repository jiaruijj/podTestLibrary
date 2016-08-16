//
//  FNDebugManager.m
//  FNMerchant
//
//  Created by JR on 16/8/5.
//  Copyright © 2016年 FeiNiu. All rights reserved.
//

#import "FNDebugManager.h"
#import "FNDebugRootViewController.h"
#import "FloatBallButton.h"
#import "NSBundle+MyLibrary.h"
//#import <UMMobClick/MobClick.h>
//#import <PgySDK/PgyManager.h>
//#import <PgyUpdate/PgyUpdateManager.h>



NSString *  kFNDotNetAPIGeneralURL = @"";
NSString *  kFNDotNetAPIMerchandiseURL = @"";
NSString *  kFNDotNetAPIShoppingURL = @"";
NSString *  kFNDotNetAPIRecommendURL = @"";
NSString *  const FNDomainTypeDidChangedNotification = @"FNDomainTypeDidChangedNotification";

static NSString *  mAppLogNetURL = @"";
static NSString *  mErrorLogNetURL = @"";

static NSString * const FeiNiuDevBundleID = @"com.feiniu.market.merchant";
static NSString * const FeiNiuOnlineBundleID = @"com.feiniu.FNMerchant";
static NSString * const FNLastDomainTypeName = @"FNLastDomainTypeName";
static NSString * const kUmengKey = @"5796c9d7e0f55a39ba0011fc";
static NSString * const kChannelId = @"蒲公英";

/**获取 Java API 的 Domain**/
/*没有都没设置默认为商家测试版*/
static NSString *kGetConfigerDomainDev = @"https://mall-mobile-api.dev1.fn";
static NSString *kGetConfigerDomainBeta = @"https://mall-mobile-api.beta1.fn";
static NSString *kGetConfigerDomainPreview = @"https://preview-interface-merchant.feiniu.com";
static NSString *kGetConfigerDomainOnline = @"https://interface-merchant.feiniu.com";



static NSString * const kBodyKey = @"body";
static NSString * const KAPIKey = @"wirelessAPI";



@interface FNDebugManager () <NSURLSessionDelegate, NSURLSessionTaskDelegate>

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) FloatBallButton *floatBallButton;
@property (nonatomic, copy)   NSString *bundleID;

@property (nonatomic, assign) BOOL enableDownloadAPI;
@property (nonatomic, strong) NSDictionary *apiDictionary;
@property (nonatomic, assign) NSInteger environmentType;

@property (nonatomic, strong) NSURLConnection *URLConnection;
@property (nonatomic, strong) NSMutableData *receivedData;
@property (nonatomic, strong) NSArray *trustedCertificates;
@property (nonatomic, copy)   void(^requestResult)(BOOL success);


@property (nonatomic, copy) NSString *domainDev;
@property (nonatomic, copy) NSString *domainBeta;
@property (nonatomic, copy) NSString *domainPreview;
@property (nonatomic, copy) NSString *domainOnline;

@end


@implementation FNDebugManager

+ (instancetype)shareManager
{
    static  FNDebugManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[FNDebugManager alloc] init];
        [manager registerNotificationObserver];
        [manager updateApiDictionaryForEnvironmentChange];
        [manager addTrustedCertificates];
        DLog(@"当前环境是：%@", [manager currentEnvString]);
    });
    return manager;
}


- (void)configDomainUrl:(NSString *)domainDev
             domainBeta:(NSString *)domainBeta
          domainPreview:(NSString *)domainPreview
           domainOnline:(NSString *)domainOnline
{
    self.domainDev = domainDev;
    self.domainBeta = domainBeta;
    self.domainPreview = domainPreview;
    self.domainOnline = domainOnline;
}

- (void)configDomainType
{
#ifdef DEBUG
    self.domainType = FNDomainTypeBeta; //调试时随便改
#else
    self.defaultDomainType = FNDomainTypeBeta; //不要修改成online，默认第一次启动环境
    [self readLastConfifegFromUserDeafealt]; // 读取上一次保存的环境
#endif
}

- (void)readLastConfifegFromUserDeafealt
{
    // 从userdefault中读取上次保存的环境
    FNDomainType lastType = [[[NSUserDefaults standardUserDefaults] valueForKey:FNLastDomainTypeName] intValue];
    if (lastType == FNDomainTypeNone) {
        // 如果是第一次启动则走默认环境
        lastType = [self defaultDomainType];
    }
    [self setDomainType:lastType]; // 设置当前domainType为之前使用的domainType
}



- (BOOL)saveChanges{
    // 设置完成之后保存信息到userdefault中
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSNumber *domainTypeNum = [NSNumber numberWithInt:_domainType];
    [userDefault setValue:domainTypeNum forKey:FNLastDomainTypeName];
    
    if ([userDefault synchronize]) {
        [self postDomainTypeDidChangeNotification];
        return YES;
    }
    return NO;
}

- (void)domainTypeResult: (FNDomainType)domainType  result:(void(^)(BOOL success))block
{
    [self configAppUrl];
    
    BOOL result = [self saveChanges];
    if (block) {
        block(result);
    }
}

//保存成功后发送通知
- (void)postDomainTypeDidChangeNotification{
    [[NSNotificationCenter defaultCenter] postNotificationName:FNDomainTypeDidChangedNotification object:@(self.domainType)];
}


#pragma mark - SDKs
/*
- (void)config3rdUnits
{
    [self configUmeng];
    [self configPgy];
}

//配置友盟参数
- (void)configUmeng
{
    UMConfigInstance.appKey = kUmengKey;
    [MobClick startWithConfigure:UMConfigInstance];
    [MobClick setAppVersion:XcodeAppVersion];
#ifdef DEBUG
    [MobClick setLogEnabled:YES];
    UMConfigInstance.channelId = kChannelId;
#endif
}


- (void)configPgy
{
    //启动基本SDK
    [[PgyManager sharedPgyManager] startManagerWithAppId:@"02a8fb3b061f31e52d10196c2696365d"];
    [[PgyManager sharedPgyManager] setEnableFeedback:NO];
    //启动更新检查SDK
    [[PgyUpdateManager sharedPgyManager] startManagerWithAppId:@"02a8fb3b061f31e52d10196c2696365d"];
#ifndef DEBUG
    [[PgyManager sharedPgyManager] checkUpdate];
#endif
}
*/
#pragma mark - setter&&getter

- (void)setDomainType:(FNDomainType)domainType
{
    if (_domainType == domainType) {
        return;
    }
    _domainType = domainType;
    
    [self configAppUrl];
    [self saveChanges];
    
}

- (void)configAppUrl
{
    if (self.isOnlineClient == YES) {// 线上客户端的时候 不管怎么设置环境都为online
        _domainType = FNDomainTypeOnline;
    }
    switch (_domainType) {
            
        case FNDomainTypeDev:{
            
            mAppLogNetURL = @"http://10.200.42.1:8089/AppCollectLogs/AddAppLog";
            mErrorLogNetURL = @"http://track.fn.com/1.gif?logtype=2";
            _hostName = @"imserver.dev.fn.com";
        }
            break;
            
        case FNDomainTypeBeta:{
            // dev and beta
            mAppLogNetURL = @"http://10.200.42.1:8089/AppCollectLogs/AddAppLog";
            mErrorLogNetURL = @"http://track.fn.com/1.gif?logtype=2";
            
            //xmpp - 现在beta,preview,online 都还没部署-现在的环境都是dev
            
            _hostName = @"wh-lvs.fn.com"; //beta
            
        }
            break;
        case FNDomainTypePreview:{
            // Preview
            mAppLogNetURL = @"http://10.201.193.157:8080/AppCollectLogs/AddAppLog";
            mErrorLogNetURL = @"http://track.fn.com/1.gif?logtype=2";
            
            _hostName = @"imserver.dev.fn.com";
            // _hostName = @"stage-im01.idc1.fn"; //preview
        }
            break;
        case FNDomainTypeNone: // none
        case FNDomainTypeOnline:{
            // Online
            mAppLogNetURL = @"http://flume.feiniu.com/AppCollectLogs/AddAppLog";
            mErrorLogNetURL = @"http://gather.feiniu.com/1.gif?logtype=2";
            
            _hostName = @"imserver.dev.fn.com";
            // _hostName = @"m.feiniu.com"; //online
        }
            break;
        default:{
        }
            break;
    }

}

- (NSString *)bundleID{
    if (!_bundleID) {
        _bundleID = [[NSBundle mainBundle] bundleIdentifier];
    }
    return _bundleID;
}

- (BOOL)isOnlineClient{
    
    if ([self.bundleID isEqualToString:(self.devBundleID?self.devBundleID:FeiNiuDevBundleID)]) {
        return NO;
    }
    return YES;
}

- (FNDomainType)defaultDomainType{
    if (_defaultDomainType) {
        return _defaultDomainType;
    }
    return [self onlineClientDomainType];
}

- (FNDomainType)fristActiveDomainType{
    return FNDomainTypeBeta;
}

- (FNDomainType)onlineClientDomainType{
    return FNDomainTypeOnline;
}


#pragma mark =======================

- (void)invocationEvent:(FNDebugEvent)invocationEvent{
    if (FNDebugEventBubble == invocationEvent) {
        _window = [[UIApplication sharedApplication] keyWindow];
        [_window addSubview:self.floatBallButton];
    }
    if (FNDebugEventNone == invocationEvent) {
        [_floatBallButton removeFromSuperview];
    }
}

- (FloatBallButton *) floatBallButton {
    if (!_floatBallButton) {
        _floatBallButton = [FloatBallButton buttonWithType:UIButtonTypeCustom];
        _floatBallButton.MoveEnable = YES;
        _floatBallButton.frame = CGRectMake([[UIScreen mainScreen] bounds].size.width - 40, [[UIScreen mainScreen] bounds].size.width - 100, 40, 40);
        UIImage *image = [UIImage imageNamed:@"Debug.bundle/images/bug" inBundle:[NSBundle myLibraryBundle] compatibleWithTraitCollection:nil];
        [_floatBallButton setImage:image forState:UIControlStateNormal];
        [_floatBallButton addTarget:self action:@selector(floatButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _floatBallButton;
}

- (void)floatButtonAction:(FloatBallButton *)button {
    if (!button.MoveEnabled) {
        [self debugAction:button];
    }
}

#pragma mark =======================

- (FNDomainType) currentEnv {
    NSNumber *number = [[NSUserDefaults standardUserDefaults] objectForKey:FNLastDomainTypeName];
    if (number) {
        return [number integerValue];
    }
    return FNDomainTypeOnline;
}

- (NSString *) currentEnvString {
    switch ([self currentEnv]) {
        case FNDomainTypeNone:
            return @"无环境";
            break;
        case FNDomainTypeDev:
            return @"开发环境";
            break;
        case FNDomainTypeBeta:
            return @"测试环境";
            break;
        case FNDomainTypePreview:
            return @"预览环境";
            break;
        case FNDomainTypeOnline:
            return @"线上环境";
            break;
        default:
            break;
    }
    return @"";
}

#pragma mark =======================

- (UIViewController *) parentViewController {
    if (!_parentViewController) {
        _parentViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    }
    return _parentViewController;
}

- (void) debugAction:(UIButton *)button {
    FNDebugRootViewController *controller = [[FNDebugRootViewController alloc] init];
    if ([self.parentViewController isKindOfClass:[UINavigationController class]]) {
        [(UINavigationController *)self.parentViewController pushViewController:controller animated:YES];
    } else {
        [[FNDebugManager topViewController].navigationController pushViewController:controller animated:YES];
    }
}

+ (UIViewController *)topViewController {
    return [self topViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
}

+ (UIViewController *)topViewController:(UIViewController *)rootViewController {
    if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *)rootViewController;
        return [self topViewController:[navigationController.viewControllers lastObject]];
    }
    if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabController = (UITabBarController *)rootViewController;
        return [self topViewController:tabController.selectedViewController];
    }
    if (rootViewController.presentedViewController) {
        return [self topViewController:rootViewController.presentedViewController];
    }
    return rootViewController;
}


- (UIView *) debugView {
    CGRect screenBound = [UIScreen mainScreen].bounds;
    CGRect shortcutFrame;
    shortcutFrame.size.width = 40.0f;
    shortcutFrame.size.height = 40.0f;
    shortcutFrame.origin.x = CGRectGetMaxX(screenBound)/2 - shortcutFrame.size.width/2;
    shortcutFrame.origin.y = CGRectGetMaxY(screenBound) - shortcutFrame.size.height - 84.0f;
    UIButton * button = [[UIButton alloc] initWithFrame:shortcutFrame];
    button.backgroundColor = [UIColor clearColor];
    button.adjustsImageWhenHighlighted = YES;
    [button setImage:[UIImage imageNamed:@"Debug.bundle/images/bug"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(debugAction:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}


#pragma mark - Public Method

+ (void)requstEnvironment
{
    [[FNDebugManager shareManager] requstEnvironment];
}

+ (void)requestAPIsResult:(void (^)(BOOL))result {
    [FNDebugManager shareManager].requestResult = result;
    [self requstEnvironment];
}

+ (void)setEnableDownloadAPI:(BOOL)flag {
    [[FNDebugManager shareManager] setEnableDownloadAPI:flag];
}

+ (void)changeEnvironment:(FNDomainType)environment
{
    FNDebugManager *shareInstance = [FNDebugManager shareManager];
    // 保存新的环境
    shareInstance.environmentType = environment;
    // 更新 保存java API 的字典和 变更PHP的相关的Domian
    [shareInstance updateApiDictionaryForEnvironmentChange];
}

+ (void)clearDocumentFile
{
    NSString *path = [[FNDebugManager shareManager] filePath];
    BOOL deleted = [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    if (!deleted) {
        DLog(@"删除缓存文件夹失败");
    }
}

#pragma mark - Get FullPath With Key
+ (NSString *)URLStringForPath:(NSString *)path
{
    if (![FNDebugManager shareManager].enableDownloadAPI) {
        return nil;
    }
    
    NSString *fullJavaPath = [[FNDebugManager shareManager] fullURLStringWithJavaPath:path];
    
    // NSAssert(fullJavaPath.length > 0, @"未找到相应下发API key:%@", path);
    return fullJavaPath ? fullJavaPath : path;
}

- (NSString *)fullURLStringWithJavaPath:(NSString *)path
{
    if (!path) {
        return nil;
    }
    // 根据 path 查询是否存在对应的下发URL
    NSString *fullURLString = [[FNDebugManager shareManager].apiDictionary objectForKey:path];
    return fullURLString.length > 0 ? fullURLString : nil;
}

#pragma mark - Private Method
- (void)requstEnvironment
{
    DLog(@"*******************  requstEnvironment ********************************");
    NSString *domainURLString = [self javaDomainForCurrentEnvironment];
    NSString *apiExtetnsionString = kDownloadAPIVersion;
    NSString *urlString = [NSString stringWithFormat:@"%@/info/getConfig/%@",domainURLString,apiExtetnsionString];
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    NSURLSessionConfiguration * config = [NSURLSessionConfiguration defaultSessionConfiguration];
    config.TLSMaximumSupportedProtocol = kTLSProtocol1;
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    //    self.session = session;
    //    NSURLSession *session = [NSURLSession sharedSession];
    __weak typeof(self) weakSelf = self;
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:
                                      ^(NSData *data, NSURLResponse *response, NSError *error) {
                                          if (data != nil) {
                                              [weakSelf handleSessionTaskCompletionData:data response:response error:error];
                                          }else{
                                              [weakSelf runResultWithSuccess:NO];
                                          }
                                          weakSelf.requestResult = nil;
                                      }];
    [dataTask resume];
}

- (void)handleSessionTaskCompletionData:(NSData *)data response:(NSURLResponse *)response error:(NSError *)error
{
    NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    DLog(@"requestAPI Response : %@",jsonDic);
    if ([jsonDic isKindOfClass:[NSDictionary class]]) {
        NSDictionary *apiContentDic = jsonDic[kBodyKey][KAPIKey];
        if (apiContentDic.count > 0) {
            [self saveEnvironmentWithDictionary:jsonDic];
            self.apiDictionary = apiContentDic;
            [self runResultWithSuccess:YES];
            return;
        }
    }
    [self runResultWithSuccess:NO];
}

- (void)addTrustedCertificates {
    if (!self.isHttps) return;
    NSString *cerPath = [[NSBundle myLibraryBundle] pathForResource:@"fn_ssl" ofType:@"cer"];
    NSData *cerData = [NSData dataWithContentsOfFile:cerPath];
    SecCertificateRef certificate = SecCertificateCreateWithData(NULL, (__bridge CFDataRef)(cerData));
    self.trustedCertificates = @[CFBridgingRelease(certificate)];
}

- (void)runResultWithSuccess:(BOOL)success {
    if (self.requestResult) {
        self.requestResult(success);
    }
}

- (BOOL)saveEnvironmentWithDictionary:(NSDictionary *)jsonDic {
    return [jsonDic writeToFile:[self filePath] atomically:YES];
}

- (void)updateApiDictionaryForEnvironmentChange {
    _apiDictionary = [self apiDictionaryForEnvironmentType:_environmentType];
}

- (NSDictionary *)apiDictionaryForEnvironmentType:(NSInteger)type
{
    NSString *filePath = [self filePath];
    NSDictionary *apiDictionary = [self apiDictionaryForPath:filePath];
    if (!apiDictionary) {
        NSString *defaultFilePath = [[NSBundle myLibraryBundle] pathForResource:[self fileName] ofType:@"plist"];
        apiDictionary = [self apiDictionaryForPath:defaultFilePath];
    }
    return apiDictionary;
}

- (NSDictionary *)apiDictionaryForPath:(NSString *)path
{
    NSDictionary *jsonDictionary = [NSDictionary dictionaryWithContentsOfFile:path];
    NSDictionary *apiDictionary = jsonDictionary[kBodyKey][KAPIKey];
    return apiDictionary;
}

#pragma mark -session delegate
- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler
{
    NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengePerformDefaultHandling;
    __block NSURLCredential *credential = nil;
    
    //1)获取trust object
    SecTrustRef trust = challenge.protectionSpace.serverTrust;
    SecTrustResultType result;
    
    //注意：这里将之前导入的证书设置成下面验证的Trust Object的anchor certificate
    SecTrustSetAnchorCertificates(trust, (__bridge CFArrayRef)self.trustedCertificates);
    
    //2)SecTrustEvaluate会查找前面SecTrustSetAnchorCertificates设置的证书或者系统默认提供的证书，对trust进行验证
    OSStatus status = SecTrustEvaluate(trust, &result);
    if (status == errSecSuccess &&
        (result == kSecTrustResultProceed ||
         result == kSecTrustResultUnspecified))
    {
        credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
        if (credential) {
            disposition = NSURLSessionAuthChallengeUseCredential;
        }
    }
    
        if (self.environmentType == FNDomainTypeDev || self.environmentType == FNDomainTypeBeta) {
    credential = [[NSURLCredential alloc] initWithTrust:challenge.protectionSpace.serverTrust];
    disposition = NSURLSessionAuthChallengeUseCredential;
        }
    
    if (completionHandler) {
        completionHandler(disposition, credential);
    }
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler
{
    NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengeCancelAuthenticationChallenge;
    __block NSURLCredential *credential = nil;
    
    //1)获取trust object
    SecTrustRef trust = challenge.protectionSpace.serverTrust;
    SecTrustResultType result;
    
    //注意：这里将之前导入的证书设置成下面验证的Trust Object的anchor certificate
    SecTrustSetAnchorCertificates(trust, (__bridge CFArrayRef)self.trustedCertificates);
    
    //2)SecTrustEvaluate会查找前面SecTrustSetAnchorCertificates设置的证书或者系统默认提供的证书，对trust进行验证
    OSStatus status = SecTrustEvaluate(trust, &result);
    if (status == errSecSuccess &&
        (result == kSecTrustResultProceed ||
         result == kSecTrustResultUnspecified))
    {
        credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
        if (credential) {
            disposition = NSURLSessionAuthChallengeUseCredential;
        }
    }
    
    if (self.environmentType == FNDomainTypeDev || self.environmentType == FNDomainTypeBeta) {
        credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
        disposition = NSURLSessionAuthChallengeUseCredential;
    }
    
    if (completionHandler) {
        completionHandler(disposition, credential);
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    DLog(@"didCompleteWithError = %@",error);
}
- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error
{
    DLog(@"didBecomeInvalidWithError = %@",error);
    
}
#pragma mark- Application Notification

- (void)applicationDidBeacomeActive:(NSNotification *)notification {
    if (!self.enableDownloadAPI) {
        return;
    }
    [self updateApiDictionaryForEnvironmentChange];// 每次去读取最新
    [FNDebugManager requstEnvironment];// 从服务器获取最新api
}

- (void)registerNotificationObserver
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBeacomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
}

- (void)removeNotificationObserver {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                              forKeyPath:UIApplicationDidBecomeActiveNotification];
}

#pragma mark - Getter

- (NSDictionary *)apiDictionary {
    if (_apiDictionary) {
        return _apiDictionary;
    }
    _apiDictionary = [self apiDictionaryForEnvironmentType:_environmentType];
    return _apiDictionary;
}

- (NSString *)filePath
{
    NSString *fileName = [self fileName];
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,  NSUserDomainMask,YES);
    NSString *documentPath = [documentPaths objectAtIndex:0];
    //        NSString *documentPath = @"/Users/fuyong/Desktop";
    NSString *filePath = [documentPath stringByAppendingPathComponent:fileName];
    NSString *filePathWithExtension = [filePath stringByAppendingPathExtension:@"plist"];
    return filePathWithExtension;
}

- (NSString *)fileName
{
    NSString *fileName = nil;
    switch (_environmentType) {
        case FNDomainTypeNone:
            fileName = @"APIInfomationOnline";
            break;
        case FNDomainTypeDev:
            fileName = @"APIInfomationDev";
            break;
        case FNDomainTypeBeta:
            fileName = @"APIInfomationBeta";
            break;
        case FNDomainTypePreview:
            fileName = @"APIInfomationPreview";
            break;
        case FNDomainTypeOnline:
            fileName = @"APIInfomationOnline";
            break;
        default:
            break;
    }
    return fileName;
}

- (NSString *)javaDomainForCurrentEnvironment
{
    NSString *javaAPIDomainString = nil;
    if (self.domainOnline||self.domainDev||self.domainPreview||self.domainBeta) {
        switch (self.environmentType) {
            case FNDomainTypeNone:
                javaAPIDomainString = self.domainOnline;
                break;
            case FNDomainTypeDev:
                javaAPIDomainString = self.domainDev;
                break;
            case FNDomainTypeBeta:
                javaAPIDomainString = self.domainBeta;
                break;
            case FNDomainTypePreview:
                javaAPIDomainString = self.domainPreview;
                break;
            case FNDomainTypeOnline:
                javaAPIDomainString = self.domainOnline;
                break;
            default:
                break;
        }
    }  else {
        switch (self.environmentType) {
            case FNDomainTypeNone:
                javaAPIDomainString = kGetConfigerDomainOnline;//online
                break;
            case FNDomainTypeDev:
                javaAPIDomainString = kGetConfigerDomainDev;
                break;
            case FNDomainTypeBeta:
                javaAPIDomainString = kGetConfigerDomainBeta;
                break;
            case FNDomainTypePreview:
                javaAPIDomainString = kGetConfigerDomainPreview;
                break;
            case FNDomainTypeOnline:
                javaAPIDomainString = kGetConfigerDomainOnline;
                break;
            default:
                break;
        }
    }

    return javaAPIDomainString;
}

@end
