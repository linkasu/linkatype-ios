//
//  AMChatTextInputView.h
//  distype
//
//  Created by amakushkin on 13.09.16.
//  Copyright © 2016 aacidov. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AMChatTextInputViewDelegate <NSObject>

@optional

- (void)needToAddToCategory:(NSString*)message;
- (void)needToSendMessage:(NSString*)message;

@end

@interface AMChatTextInputView : UIView

@property (weak) id<AMChatTextInputViewDelegate> delegate;

@end
