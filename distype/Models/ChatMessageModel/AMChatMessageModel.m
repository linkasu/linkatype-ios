//
//  AMChatMessageModel.m
//  distype
//
//  Created by amakushkin on 13.09.16.
//  Copyright © 2016 aacidov. All rights reserved.
//

#import "AMChatMessageModel.h"

@implementation AMChatMessageModel

- (instancetype)init
{
    self = [super init];
    
    if (self != nil)
    {
        self.chatMessageTimestamp = [[NSDate date] timeIntervalSince1970];
    }
    
    return self;
}

@end
