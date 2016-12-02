//
//  ActiveChatViewController.h
//  distype
//
//  Created by amakushkin on 13.09.16.
//  Copyright © 2016 aacidov. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AMConversationModel, AMDBController;

@interface AMActiveChatViewController : UIViewController

@property (nonatomic, strong) AMDBController *db;
@property (strong) AMConversationModel *chat;

@end
