//
//  AMChatTableViewCell.m
//  distype
//
//  Created by amakushkin on 30.09.16.
//  Copyright © 2016 aacidov. All rights reserved.
//

#import "AMChatTableViewCell.h"
#import "AMConversationModel.h"

@implementation AMChatTableViewCell

- (void)setConversation:(AMConversationModel *)conversation {
    _conversation = conversation;
    
    self.textLabel.text = conversation.conversationTitle;
}


+ (NSString*)cellId {
    return @"AMChatTableViewCell";
}

@end
