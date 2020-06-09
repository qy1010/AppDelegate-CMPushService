//
//  AppDelegate+CMPushService.m
//  StandardSampleDemo
//
//  Created by 吴述雄 on 2019/11/18.
//  Copyright © 2019 Triumen. All rights reserved.
//

#import "AppDelegate+CMPushService.h"


@implementation AppDelegate (CMPushService)

- (void)registerPushSericesWithApplication:(UIApplication *)application launchOptions:(NSDictionary *)launchOptions {
    
    application.applicationIconBadgeNumber = 0;
    
    if (@available(iOS 10.0, *)) {
        // iOS 10 later
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        // 必须写代理，不然无法监听通知的接收与点击事件
        center.delegate = self;
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert) completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (!error && granted) {
                //用户点击允许
                NSLog(@"注册成功");
            } else {
                //用户点击不允许
                NSLog(@"注册失败");
            }
        }];
        
    } else {
        // iOS 8 later
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeBadge | UIUserNotificationTypeAlert | UIUserNotificationTypeSound) categories:nil];
        [application registerUserNotificationSettings:settings];
    }
    /// 注意这里注册远程推送
    [application registerForRemoteNotifications];
    
}


#pragma mark - iOS 10
#pragma mark - UNUserNotificationCenterDelegate
/// iOS 10收到消息
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler  API_AVAILABLE(ios(10.0)) {
    if ([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        //远程推送
        [self didReceiveMessage:notification.request.content.userInfo];
    } else {
        //本地推送
    }
    // Required
    // iOS 10 之后 前台展示推送的形式
    completionHandler(UNNotificationPresentationOptionAlert);
}

/// 点击推送消息
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler  API_AVAILABLE(ios(10.0)) {
    NSDictionary *userInfo = response.notification.request.content.userInfo;
    if (userInfo[@"aps"][@"data"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"CMUserClickNotificationData" object:userInfo[@"aps"][@"data"]];
    }
    completionHandler();
}

#pragma mark - iOS 8
/// iOS 8 收到消息&点击推送消息都走这里
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    if (application.applicationState == UIApplicationStateActive) {
        [self didReceiveMessage:userInfo];
    } else if (application.applicationState == UIApplicationStateInactive) {
        /// 后台点击推送进来
        if (userInfo[@"aps"][@"data"]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"CMUserClickNotificationData" object:userInfo[@"aps"][@"data"]];
        }
    }
    completionHandler(UIBackgroundFetchResultNewData);
}

#pragma mark - 注册结果
/// 注册成功
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    //保存deviceToken
    NSString *deviceTokenString;
    if (@available(iOS 13.0, *)) {
        NSMutableString *deviceTokenMutString = [NSMutableString string];
        const char *bytes = deviceToken.bytes;
        NSInteger count = deviceToken.length;
        for (int i = 0; i < count; i++) {
            [deviceTokenMutString appendFormat:@"%02x", bytes[i]&0x000000FF];
        }
        deviceTokenString = deviceTokenMutString.copy;
    } else {
        deviceTokenString = [[[[deviceToken description] stringByReplacingOccurrencesOfString:@"<"withString:@""] stringByReplacingOccurrencesOfString:@">" withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@""];
    }
    NSLog(@"=================================== deviceTokenString：%@", deviceTokenString);
    NSUserDefaults *udf = [NSUserDefaults standardUserDefaults];
    [udf setValue:deviceTokenString forKey:@"device_token"];
    [udf synchronize];
}
/// 注册失败
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSUserDefaults *udf = [NSUserDefaults standardUserDefaults];
    [udf setValue:nil forKey:@"device_token"];
    [udf synchronize];
}


#pragma mark - actions
- (void)didReceiveMessage:(NSDictionary *)userInfo {
    
    NSLog(@"收到推送：%@",userInfo);
}

@end
