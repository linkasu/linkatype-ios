//
//  AMConversationModel.h
//  distype
//
//  Created by amakushkin on 14.09.16.
//  Copyright © 2016 aacidov. All rights reserved.
//

#import <Realm/Realm.h>

@interface AMConversationModel : RLMObject

@property (assign) NSTimeInterval conversationTimestamp;
@property (strong) NSString *conversationUniqId;
@property (strong) NSString *conversationTitle;

@end
