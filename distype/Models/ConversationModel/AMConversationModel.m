//
//  AMConversationModel.m
//  distype
//
//  Created by amakushkin on 14.09.16.
//  Copyright © 2016 aacidov. All rights reserved.
//

#import "AMConversationModel.h"

@implementation AMConversationModel

- (instancetype)init
{
    self = [super init];
    
    if (self != nil)
    {
        self.conversationTimestamp = [[NSDate date] timeIntervalSince1970];
        self.conversationUniqId = [NSUUID UUID].UUIDString;
    }
    
    return self;
}

@end
