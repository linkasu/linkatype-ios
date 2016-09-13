//
//  AppDelegate.m
//  distype
//
//  Created by Иван Труфанов on 29.08.16.
//  Copyright © 2016 aacidov. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    if (self.window == nil) {
        self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    }
    
    return YES;
}

@end
