//
//  AMDBController.m
//  distype
//
//  Created by Mike Kholomeev on 12/2/16.
//  Copyright © 2016 aacidov. All rights reserved.
//

#import "AMDBController.h"
#import "AMChatMessageModel.h"
#import "AMConversationModel.h"


@implementation AMDBController

#pragma mark - Requests
- (RLMResults *)allChats
{
    RLMResults *realmResults = [AMConversationModel allObjects];
    
    return realmResults;
}

- (RLMResults *)allWordsForChatID:(NSString *)chatID
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"conversationUniqId == %@", chatID];
    RLMResults *realmResults = [AMChatMessageModel objectsWithPredicate:predicate];
    
    return realmResults;
}

- (RLMResults *)allWordsForCategoryID:(NSString*)categoryUniqId
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"categoryUniqId == %@", categoryUniqId];
    RLMResults *realmResults = [AMChatMessageModel objectsWithPredicate:predicate];
    
    return realmResults;
}

- (RLMResults *)chatForTitle:(NSString*)title
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"conversationTitle == %@", title];
    RLMResults *realmResults = [AMConversationModel objectsWithPredicate:predicate];
    
    if (realmResults.count == 0)
    {
//        self.createChatWithTitle(title);
        
        realmResults = [AMConversationModel objectsWithPredicate:predicate];
    }
    
    return realmResults;
}

#pragma mark - Creations
- (void)createChatWithTitle:(NSString *)title
{
    AMConversationModel *conversationModel = [[AMConversationModel alloc] init];
    conversationModel.conversationTitle = title;
    conversationModel.conversationTimestamp = [[NSDate date] timeIntervalSince1970];
    conversationModel.conversationUniqId = [NSUUID UUID].UUIDString;
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    [realm addObject:conversationModel];
    [realm commitWriteTransaction];
}

@end
