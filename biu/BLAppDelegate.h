//
//  AppDelegate.h
//  biu
//
//  Created by Tony Wu on 5/5/15.
//  Copyright (c) 2015 BiuLove. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "XMPPFramework.h"
#import "WXApi.h"
#import "WeiboSDK.h"


#define IS_IPHONE_4S (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)480) < DBL_EPSILON)
#define IS_IPHONE_5 (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)568) < DBL_EPSILON)
#define IS_IPHONE_6 (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)667) < DBL_EPSILON)
#define IS_IPHONE_6_PLUS (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)736) < DBL_EPSILON)


#ifndef LoginDemo_Define_h
#define LoginDemo_Define_h

#define kAppDescription      @"0211"//随便的一串数字
#define kWeiXinAppId         @"wx67c27b7cc14de1aa"
#define kWeiXinAppSecret     @"3570b565f219a04a10d3c953210596af"

#define kWeiBoAppKey         @"747887283"
#define kWeiBoAppSecret      @"804105ed166fd665b1904c69bea171e3"
#define kWeiBoRedirectURL    @"https://api.weibo.com/oauth2/default.html"

#define kAccessToken   @"AccessToken"
#define kOpenId        @"OpenId"
#define kRefreshToken  @"RefreshToken"

#define kMAMapKey      @"735493b70b571f4339f62b071bf068b3"
#endif

@protocol BLMessageDelegate <NSObject>
@required
- (void)newMessageReceived:(NSDictionary *)message;

@end

@protocol BLMatchNotificationDelegate <NSObject>

@optional
- (void)receiveMatchedNotification:(User *)matchedUser;
- (void)receiveAcceptedNotification:(User *)matchedUser;
- (void)receiveRejectedNotification;
- (void)receiveCloseNotification;

@end

@interface BLAppDelegate : UIResponder <UIApplicationDelegate, XMPPStreamDelegate,WXApiDelegate,WeiboSDKDelegate,WBHttpRequestDelegate> {
    XMPPStream *xmppStream;
    BOOL isOpen;
}

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) User *currentUser;
@property (strong, nonatomic) NSString *deviceToken;

@property (strong, nonatomic) UINavigationController *welNavController;
@property (strong, nonatomic) UIViewController *masterNavController;

@property (strong, nonatomic, readonly) XMPPStream *xmppStream;
@property (weak, nonatomic) id<BLMessageDelegate> messageDelegate;
@property (weak, nonatomic) id<BLMatchNotificationDelegate> notificationDelegate;

@property (strong, nonatomic)NSString *access_token;
@property (strong, nonatomic)NSString *openid;//第三方登录唯一标识
@property (strong, nonatomic)NSString *username;//用户名
@property (strong, nonatomic)NSString *avatar_url;//头像地址
@property (strong, nonatomic)NSString *avatar_large_url;//大像素头像

@property (strong, nonatomic)WeiboSDK *weiboOAth;

- (BOOL)connect;
- (void)disconnect;

@end







