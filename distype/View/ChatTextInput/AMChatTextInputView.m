/*-
 * Copyright © 2016  Alex Makushkin
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHORS AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHORS OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 */

//
//  AMChatTextInputView.m
//  distype
//
//  Created by amakushkin on 13.09.16.
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

#pragma mark - Setters

- (void)setHidden:(BOOL)hidden {
    super.hidden = hidden;
    
    if (hidden == YES) {
        [self.messageTextField resignFirstResponder];
    }
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

- (void)hideKeyboard {
    [self.messageTextField resignFirstResponder];
}

@end
