//
//  FNDebugManager.h
//  FNMerchant
//
//  Created by JR on 16/8/5.
//  Copyright © 2016年 FeiNiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FNEnvironmentHeader.h"


#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define SCREEN_WIDTH  [UIScreen mainScreen].bounds.size.width
#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self;

#ifdef DEBUG
#define DLog(...) NSLog(__VA_ARGS__)
#else
#define DLog(...)
#endif

/**
 * 环境类型
 */
typedef NS_ENUM(NSInteger, FNDomainType) {
    FNDomainTypeNone,           // 没有环境
    FNDomainTypeDev,            // 开发环境
    FNDomainTypeBeta,           // 测试环境
    FNDomainTypePreview,        // 预览环境
    FNDomainTypeOnline,         // 线上环境
};

/**
 *  呼出方式
 */
typedef NS_ENUM (NSInteger , FNDebugEvent) {
    FNDebugEventNone = 0,    // 静默模式
    FNDebugEventBubble,      // 通过悬浮小球呼出
} ;

typedef void(^saveSuccessBlock)();
typedef void(^saveFailureBlock)();

/** 环境切换的通知 */
extern NSString * FNChangeEnvironmentNotificationName;
/** domain地址改变的 Notification */
extern NSString * const FNDomainTypeDidChangedNotification;

@interface FNDebugManager : NSObject


/**
 *  设置当前环境
 */
@property (nonatomic, assign) FNDomainType domainType;
/**
 *  默认的启动环境 如果不配置那么为 online
 */
@property (nonatomic, assign) FNDomainType defaultDomainType;
/**
 *  是否是上线,优先级最高
 */
@property (nonatomic, assign, readonly) BOOL isOnlineClient;
/**
 *  是否是https
 */
@property (nonatomic, assign) BOOL isHttps;
/**
 *  测试环境的bundleID
 */
@property (nonatomic, copy) NSString *devBundleID;
@property (nonatomic, copy) NSString *cid;
@property (nonatomic, copy) NSString *deviceToken;
//XMPP服务器 域名
@property (nonatomic, copy) NSString *hostName;

@property (nonatomic, copy) saveSuccessBlock saveSuccessBlock;
@property (nonatomic, copy) saveFailureBlock saveFailureBlock;

/**
 *  父控制器
 */
@property (nonatomic,strong) UIViewController *parentViewController;



/**
 *   在开启debug模式下自动显示debug图窗
 //1、全局模式，在主窗体展示之后，进行设置
 [FNDebugManager shareManager].parentViewController = self;
 [[FNDebugManager shareManager] invocationEvent:FNDebugEventBubble];
 //2、内嵌模式，在某一个页面单独设置
 [FNDebugManager shareManager].parentViewController = self;
 [self.view addSubview:[[FNDebugManager shareManager] debugView]];
 */



/**
 *  单例
 */
+ (instancetype)shareManager;

/**
 *  回调成功的状态
 *
 */
- (void)domainTypeResult:(FNDomainType)domainType  result:(void(^)(BOOL success))result;

/**
 *  配置当前环境根据debug和release
 */
- (void)configDomainType;

/**
 *  配置第三方
 */
//- (void)config3rdUnits;

/**
 *  设置debug界面的cid和deviceToken
 *
 *  @param cid         
 *  @param deviceToken
 */
- (void)configCid:(NSString *)cid deviceToken:(NSString *)deviceToken;

/**
 *  配置各个环境的Url
 */
- (void)configDomainUrl:(NSString *)domainDev
             domainBeta:(NSString *)domainBeta
          domainPreview:(NSString *)domainPreview
           domainOnline:(NSString *)domainOnline;


/**
 *  保存环境
 *
 *  @param success 成功回调
 *  @param failure 失败回调
 */
- (void)saveEviromentChnageSuccess:(saveSuccessBlock)success failure:(saveFailureBlock)failure;

/**
 *  设置Debug呼出样式
 *
 *  @return
 */
- (void)invocationEvent:(FNDebugEvent)invocationEvent;

/**
 *  返回当前的环境类型，具体的逻辑判断，由业务方进行逻辑处理
 *
 */
- (FNDomainType) currentEnv;

/**
 *  当前环境值
 *
 *  @return 当前环境的字符串，用于输出
 */
- (NSString *) currentEnvString;

/**
 *  DEBUG模式下，提供一个展示的入口视图
 *  每次调用均会创建，业务方需要自己持有
 */
- (UIView *) debugView;

/**
 * 读取最后一次配置的domain信息
 */
- (void)readLastConfifegFromUserDeafealt;

/**
 * 请求 java api 数据
 */
+ (void)requstEnvironment;

/**
 *  请求API带状态值
 *
 */
+ (void)requestAPIsResult:(void(^)(BOOL success))result;

/**
 *  是否使用下发的 API YES 为使用
 */
+ (void)setEnableDownloadAPI:(BOOL)flag;

/**
 *  改变环境
 */
+ (void)changeEnvironment:(FNDomainType)environment;

/**
 *  取得下发的API文件路径
 */
+ (NSString *)URLStringForPath:(NSString *)path;

/**
 *  清理缓存
 */
+ (void)clearDocumentFile;


@end


