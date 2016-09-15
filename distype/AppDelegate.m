//
//  AppDelegate.m
//  distype
//
//  Created by Иван Труфанов on 29.08.16.
//  Copyright © 2016 aacidov. All rights reserved.
//

#import <Realm/Realm.h>

#import "AppDelegate.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    if (self.window == nil) {
        self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    }
    
    RLMRealmConfiguration *configRealm = [RLMRealmConfiguration defaultConfiguration];
    configRealm.schemaVersion = 1;
    [RLMRealmConfiguration setDefaultConfiguration:configRealm];
    
    return YES;
}

@end
