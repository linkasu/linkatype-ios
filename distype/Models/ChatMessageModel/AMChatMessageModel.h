//
//  AMChatMessageModel.h
//  distype
//
//  Created by amakushkin on 13.09.16.
//  Copyright © 2016 aacidov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Realm/Realm.h>

@interface AMChatMessageModel : RLMObject

@property (assign) NSTimeInterval chatMessageTimestamp;
@property (strong) NSString *conversationUniqId;
@property (strong) NSString *categoryUniqId;
@property (strong) NSString *text;

@end
