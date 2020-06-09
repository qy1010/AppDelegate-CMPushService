//
//  AppDelegate+CMPushService.h
//  StandardSampleDemo
//
//  Created by 吴述雄 on 2019/11/18.
//  Copyright © 2019 Triumen. All rights reserved.
//

#import "AppDelegate.h"
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
#import <UserNotifications/UserNotifications.h>
#endif


NS_ASSUME_NONNULL_BEGIN

@interface AppDelegate (CMPushService) <UNUserNotificationCenterDelegate>

- (void)registerPushSericesWithApplication:(UIApplication *)application launchOptions:(NSDictionary *)launchOptions;

@end

NS_ASSUME_NONNULL_END
