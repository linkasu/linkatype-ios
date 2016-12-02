//
//  ActiveChatViewController.h
//  distype
//
//  Created by amakushkin on 13.09.16.
//  Copyright © 2016 aacidov. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AMConversationModel;

@interface AMActiveChatViewController : UIViewController

@property (strong) AMConversationModel *conversation;

@end
