//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//

#import <Bugly/Bugly.h>

#import "helpdesk_sdk.h"
#import "HelpDeskUI.h"

#import "HDChatViewController.h"
#import "SCLoginManager.h"

#import "JPUSHService.h"
// iOS10注册APNs所需头文件
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif
