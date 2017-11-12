//
//  AMDBController.h
//  distype
//
//  Created by Mike Kholomeev on 12/2/16.
//  Copyright © 2016 aacidov. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RLMResults, AMConversationModel, AMChatMessageModel, AMCategoryModel;

@interface AMDBController : NSObject

- (RLMResults *)allChats;
- (RLMResults *)allCategories;
- (RLMResults *)allWordsForChatID:(NSString *)chatId;
- (RLMResults *)allWordsForCategoryID:(NSString *)categoryUniqId;
- (AMConversationModel *)chatForTitle:(NSString *)title;
- (AMCategoryModel *)categoryWithID:(NSString*)categoryUniqId;
- (AMCategoryModel *)categoryWithTitle:(NSString*)categoryTitle;

- (BOOL)createChatWithTitle:(NSString *)title;
- (BOOL)createCategoryWithTitle:(NSString *)title;
- (void)addMessage:(AMChatMessageModel *)message;

- (BOOL)deleteChat:(AMConversationModel *)conversation;
- (BOOL)deleteWord:(AMChatMessageModel *)message;
- (BOOL)deleteCategory:(AMCategoryModel*)category;

@end
