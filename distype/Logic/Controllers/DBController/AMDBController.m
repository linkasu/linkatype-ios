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
#import "AMCategoryModel.h"


@implementation AMDBController

#pragma mark - Requests
- (RLMResults< AMConversationModel *> *)allChats
{
    RLMResults *realmResults = [AMConversationModel allObjects];
    
    return realmResults;
}

- (RLMResults< AMCategoryModel *> *)allCategories
{
    RLMResults *realmResults = [AMCategoryModel allObjects];
    
    return realmResults;
}

- (RLMResults< AMChatMessageModel *> *)allWordsForChatID:(NSString *)chatId
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"conversationUniqId == %@", chatId];
    RLMResults *realmResults = [AMChatMessageModel objectsWithPredicate:predicate];
    
    return realmResults;
}

- (RLMResults< AMCategoryModel *> *)allWordsForCategoryID:(NSString*)categoryUniqId
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"categoryUniqId == %@", categoryUniqId];
    RLMResults *realmResults = [AMChatMessageModel objectsWithPredicate:predicate];
    
    return realmResults;
}

- (AMConversationModel *)chatForTitle:(NSString*)title
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"conversationTitle == %@", title];
    RLMResults *realmResults = [AMConversationModel objectsWithPredicate:predicate];
    
    if (realmResults.count == 0)
    {
        [self createChatWithTitle:title];
        realmResults = [AMConversationModel objectsWithPredicate:predicate];
    }
    
    return [realmResults firstObject];
}

- (AMCategoryModel *)categoryWithID:(NSString*)categoryUniqId
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"categoryUniqId == %@", categoryUniqId];
    RLMResults *realmResults = [AMCategoryModel objectsWithPredicate:predicate];
    
    return [realmResults firstObject];
}

- (AMCategoryModel *)categoryWithTitle:(NSString*)title
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"categoryTitle == %@", title];
    RLMResults *realmResults = [AMCategoryModel objectsWithPredicate:predicate];
    
    if (realmResults.count == 0)
    {
        [self createCategoryWithTitle:title];
        realmResults = [AMCategoryModel objectsWithPredicate:predicate];
    }
    
    return [realmResults firstObject];
}

#pragma mark - Deletion
- (BOOL)deleteChat:(AMConversationModel *)conversation
{
    NSString *chatId = conversation.conversationUniqId;
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    
    RLMResults *messages = [self allWordsForChatID:chatId];
    [realm deleteObjects:messages];
    [realm deleteObject:conversation];
    
    return [realm commitWriteTransaction:nil];
}

- (BOOL)deleteWord:(AMChatMessageModel*)message
{
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    message.categoryUniqId = nil;
    
    return [realm commitWriteTransaction:nil];
}

- (BOOL)deleteCategory:(AMCategoryModel*)category
{
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    [realm deleteObject:category];
    
    return [realm commitWriteTransaction:nil];
}

#pragma mark - Creations
- (BOOL)createChatWithTitle:(NSString *)title
{
    AMConversationModel *conversationModel = [AMConversationModel new];
    conversationModel.conversationTitle = title;
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    [realm addObject:conversationModel];
    
    return [realm commitWriteTransaction:nil];
}

- (BOOL)createCategoryWithTitle:(NSString *)title
{
    AMCategoryModel *category = [AMCategoryModel new];
    category.categoryTitle = title;

    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    [realm addObject:category];
    
    return [realm commitWriteTransaction:nil];
}

- (void)addMessage:(AMChatMessageModel *)message
{
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    [realm addObject:message];
    [realm commitWriteTransaction];
}

@end
