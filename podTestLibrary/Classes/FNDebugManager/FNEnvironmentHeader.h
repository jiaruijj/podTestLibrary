//
//  FNEnvironmentHeader.h
//  FNNetworkingDemo
//
//  Created by HG on 16/3/29.
//  Copyright © 2016年 feiniu. All rights reserved.
//

extern NSString *kFNDotNetAPIGeneralURL;
extern NSString *kFNDotNetAPIMerchandiseURL;
extern NSString *kFNDotNetAPIShoppingURL;
extern NSString *kFNDotNetAPIRecommendURL;

static NSString *const kDownloadAPIVersion = @"i100";

static NSString *const kGetHomePage = @"getHomePage";
static NSString *const kGetBottomBarInfo = @"getBottomBarInfo";
static NSString *const kGetImageCaptcha = @"getImageCaptcha";
static NSString *const kGetMessageListByCode = @"getMessageListByCode";
static NSString *const kGetMessageSettings = @"getMessageSettings";
static NSString *const kGetMessageSettingsByCode = @"getMessageSettingsByCode";
static NSString *const kGetMessageTypeList = @"getMessageTypeList";
static NSString *const kGetSecuritySettings = @"getSecuritySettings";
static NSString *const kGetStoreBiInfo = @"getStoreBiInfo";
static NSString *const kGetStoreBiSetingInfo = @"getStoreBiSetingInfo";
static NSString *const kGetStoreDsrInfo = @"getStoreDsrInfo";
static NSString *const kGetStoreInfo = @"getStoreInfo";
static NSString *const kGetStoreModeInfo = @"getStoreModeInfo";
static NSString *const kGetStoreModelSetting = @"getStoreModelSetting";
static NSString *const kGetToken = @"getToken";
static NSString *const kGetTotalMessageNum = @"getTotalMessageNum";
static NSString *const kIsHavePermission = @"isHavePermission";
static NSString *const kLogOut = @"logOut";
static NSString *const kLogin = @"login";
static NSString *const kResetPassword = @"resetPassword";
static NSString *const kSaveMessageSettingsByCode = @"saveMessageSettingsByCode";
static NSString *const kSaveSecuritySettings = @"saveSecuritySettings";
static NSString *const kSaveStoreBiSetingInfo = @"saveStoreBiSetingInfo";
static NSString *const kSaveStoreModelSetting = @"saveStoreModelSetting";
static NSString *const kSendCaptcha = @"sendCaptcha";
static NSString *const kValidateToGetContactInfo = @"validateToGetContactInfo";
static NSString *const kValidateUserIdentity = @"validateUserIdentity";
static NSString *const kReportDeviceCid = @"reportDeviceCid";

//one part of home api
static NSString *const kSaveStoreBiSort = @"saveStoreBiSort";
static NSString *const kSaveStoreModelSort = @"saveStoreModelSort";
//message api
static NSString *const kUploadMessagePhoto = @"uploadPicMsg";                     //上传聊天图片
static NSString *const kGetFriend= @"getFriend";                             //获取好友列表
static NSString *const kSearchRecentContact = @"searchRecentContact";             //搜索最近联系人
static NSString *const kGetHistoryMsg = @"getHistoryMsg";                         //查询历史消息
static NSString *const kGetUserInfo = @"getUserInfo";                             //获取用户信息
static NSString *const kSetUserSign = @"setUserSign";                             //设置用户签名
static NSString *const kGetStatus = @"getStatus";                                //批量获取联系人的状态 - 批量接口
static NSString *const kGetUserInfoList = @"getUserInfoList";                    //批量获取联系人信息  - 批量接口
