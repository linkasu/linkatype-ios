//
//  AMConversationManager.h
//  distype
//
//  Created by amakushkin on 14.09.16.
//  Copyright © 2016 aacidov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Realm/Realm.h>

#import "AMConversationModel.h"

@interface AMConversationManager : NSObject

+ (instancetype)sharedInstance;

- (void)removeConversationWithUniqId:(NSString*)uniqId;
- (void)addNewConversationWithTitle:(NSString*)title;
- (NSArray<AMConversationModel*>*)getAllConversations;

@end
