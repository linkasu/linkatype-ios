//
//  AMConversationManager.m
//  distype
//
//  Created by amakushkin on 14.09.16.
//  Copyright © 2016 aacidov. All rights reserved.
//

#import "AMConversationManager.h"

@implementation AMConversationManager

+ (instancetype)sharedInstance {
    static AMConversationManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[AMConversationManager alloc] init];
    });
    
    return sharedInstance;
}

- (void)removeConversationWithUniqId:(NSString*)uniqId {
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"conversationUniqId == %@", uniqId];
    RLMResults *resultsConversations = [AMConversationModel objectsWithPredicate:predicate];
    
    [realm deleteObjects:resultsConversations];
    
    [realm commitWriteTransaction];
}

- (NSArray<AMConversationModel*>*)getAllConversations {
    NSMutableArray *resultArray = [[NSMutableArray alloc] init];
    RLMResults *resultsConversations = [AMConversationModel allObjects];
    
    for (RLMObject *obj in resultsConversations) {
        [resultArray addObject:obj];
    }
    
    return resultArray;
}

- (void)addNewConversationWithTitle:(NSString*)title {
    AMConversationModel *conversation = [[AMConversationModel alloc] init];
    RLMRealm *realm = [RLMRealm defaultRealm];
    
    [realm beginWriteTransaction];
    
    conversation.conversationUniqId = [NSUUID UUID].UUIDString;
    conversation.conversationTitle = title;
    conversation.conversationTimestamp = [[NSDate date] timeIntervalSince1970];
    
    [realm addObject:conversation];
    
    [realm commitWriteTransaction];
}

@end
