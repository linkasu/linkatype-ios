//
//  AMChatTextInputView.m
//  distype
//
//  Created by amakushkin on 13.09.16.
//  Copyright © 2016 aacidov. All rights reserved.
//

#import "AMChatTextInputView.h"
#import "AMMessageTextFieldView.h"

@interface AMChatTextInputView ()
<
UITextFieldDelegate
>

- (void)initialize;

@property (strong, nonatomic) IBOutlet UIView *view;
@property (strong, nonatomic) IBOutlet AMMessageTextFieldView *messageTextField;

@end

@implementation AMChatTextInputView

#pragma mark - Initialization

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    [[UINib nibWithNibName:@"AMChatTextInputView" bundle:[NSBundle mainBundle]] instantiateWithOwner:self options:nil];
    [self addSubview:self.view];
    self.view.frame = self.bounds;
    
    [self initialize];
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    [self initialize];
    
    return self;
}

- (void)initialize {
    self.messageTextField.delegate = self;
}

#pragma mark - Action Handlers

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([self.delegate isKindOfClass:[NSNull class]] == NO
        && self.delegate != nil) {
        if ([self.delegate respondsToSelector:@selector(needToSendMessage:)] == YES) {
            [self.delegate needToSendMessage:self.messageTextField.text];
        }
    }
    
    textField.text = nil;
    [textField resignFirstResponder];
    
    return YES;
}

- (IBAction)addButtonPressed:(UIButton *)sender {
    if ([self.delegate isKindOfClass:[NSNull class]] == NO
        && self.delegate != nil) {
        if ([self.delegate respondsToSelector:@selector(needToAddToCategory:)] == YES) {
            [self.delegate needToAddToCategory:self.messageTextField.text];
        }
    }
}

- (IBAction)sendButtonPressed:(UIButton *)sender {
    if ([self.delegate isKindOfClass:[NSNull class]] == NO
        && self.delegate != nil) {
        if ([self.delegate respondsToSelector:@selector(needToSendMessage:)] == YES) {
            [self.delegate needToSendMessage:self.messageTextField.text];
            self.messageTextField.text = nil;
        }
    }
}

@end
