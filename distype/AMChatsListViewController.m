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
//  AMChatsListViewController.m
//  distype
//
//  Created by amakushkin on 13.09.16.
//

#import <LGAlertView.h>

#import "AMActiveChatViewController.h"
#import "AMChatsListViewController.h"
#import "AMConversationModel.h"
#import "AMChatTableViewCell.h"
#import "AMChatMessageModel.h"

@interface AMChatsListViewController ()

- (BOOL)isTextEmpty:(NSString*)text;

@property (strong) NSString *addChatTitle;
@property (strong) RLMResults *conversationsArray;

@end

@implementation AMChatsListViewController

- (void)initialize {
    self.addChatTitle = @"ADD NEW CHAT";
    
    self.conversationsArray = [AMConversationModel allObjects];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initialize];
}

- (BOOL)isTextEmpty:(NSString*)text {
    BOOL result = NO;
    
    if (text == nil
        || [text isEqualToString:@""] == YES) {
        result = YES;
    } else {
        NSRegularExpression *regexp = [[NSRegularExpression alloc] initWithPattern:@"^[ ]+$"
                                                                           options:NSRegularExpressionAnchorsMatchLines
                                                                             error:nil];
        if ([regexp matchesInString:text options:0 range:NSMakeRange(0, text.length)].count > 0) {
            result = YES;
        }
    }
    
    return result;
}

#pragma mark - Segue

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    BOOL result = YES;
    
    if ([sender isKindOfClass:[UITableViewCell class]] == YES) {
        UITableViewCell *cell = (UITableViewCell*)sender;
        
        if ([cell.textLabel.text isEqualToString:self.addChatTitle] == YES) {
            result = NO;
        }
    }
    
    return result;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[AMActiveChatViewController class]] == YES
        && [sender isKindOfClass:[AMChatTableViewCell class]] == YES) {
        AMActiveChatViewController *controller = (AMActiveChatViewController*)segue.destinationViewController;
        AMChatTableViewCell *cell = (AMChatTableViewCell*)sender;
        
        controller.conversation = cell.conversation;
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.section) {
        case 0: {
            __weak typeof(self) weakSelf = self;
            LGAlertView *alertView = [[LGAlertView alloc] initWithTextFieldsAndTitle:@"Create new chat"
                                                                             message:@"Enter name of new chat"
                                                                  numberOfTextFields:1
                                                              textFieldsSetupHandler:nil
                                                                        buttonTitles:@[@"Ok"]
                                                                   cancelButtonTitle:@"Cancel"
                                                              destructiveButtonTitle:nil
                                                                       actionHandler:^(LGAlertView *alertView, NSString *title, NSUInteger index) {
                                                                           __strong typeof(weakSelf) self = weakSelf;
                                                                           
                                                                           UITextField *textField = [alertView.textFieldsArray objectAtIndex:index];
                                                                           NSString *chatTitle = textField.text;
                                                                           if ([self isTextEmpty:chatTitle] == YES) {
                                                                               return;
                                                                           }
                                                                           
                                                                           NSPredicate *predicate = [NSPredicate predicateWithFormat:@"conversationTitle == %@", chatTitle];
                                                                           RLMResults *realmResults = [AMConversationModel objectsWithPredicate:predicate];
                                                                           
                                                                           if (realmResults.count == 0) {
                                                                               AMConversationModel *conversationModel = [[AMConversationModel alloc] init];
                                                                               conversationModel.conversationTitle = chatTitle;
                                                                               conversationModel.conversationTimestamp = [[NSDate date] timeIntervalSince1970];
                                                                               conversationModel.conversationUniqId = [NSUUID UUID].UUIDString;
                                                                               
                                                                               RLMRealm *realm = [RLMRealm defaultRealm];
                                                                               [realm beginWriteTransaction];
                                                                               [realm addObject:conversationModel];
                                                                               [realm commitWriteTransaction];
                                                                               
                                                                               self.conversationsArray = [AMConversationModel allObjects];
                                                                               
                                                                               dispatch_async(dispatch_get_main_queue(), ^{
                                                                                   [self.tableView reloadData];
                                                                               });
                                                                           } else {
                                                                               [textField resignFirstResponder];
                                                                               LGAlertView *errorAlert = [[LGAlertView alloc] initWithTitle:@"Error"
                                                                                                                                    message:@"Chat is already exist"
                                                                                                                                      style:LGAlertViewStyleAlert
                                                                                                                               buttonTitles:@[@"Ok"]
                                                                                                                          cancelButtonTitle:nil
                                                                                                                     destructiveButtonTitle:nil];
                                                                               errorAlert.cancelOnTouch = NO;
                                                                               [errorAlert showAnimated:YES completionHandler:nil];
                                                                           }
                                                                       }
                                                                       cancelHandler:nil
                                                                  destructiveHandler:nil];
            alertView.cancelOnTouch = NO;
            [alertView showAnimated:YES completionHandler:nil];
            break;
        }
    }
}

#pragma mark - UITableViewDataSource

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        AMChatTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        
        RLMRealm *realm = [RLMRealm defaultRealm];
        [realm beginWriteTransaction];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"conversationUniqId == %@", cell.conversation.conversationUniqId];
        RLMResults *messages = [AMChatMessageModel objectsWithPredicate:predicate];
        [realm deleteObjects:messages];
        [realm deleteObject:cell.conversation];
        
        [realm commitWriteTransaction];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section != 0) {
        return YES;
    } else {
        return NO;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 1;
            
        case 1:
            return self.conversationsArray.count;
            
        default:
            return 0;
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AMChatTableViewCell *cell = (AMChatTableViewCell*)[tableView dequeueReusableCellWithIdentifier:[AMChatTableViewCell cellId] forIndexPath:indexPath];
    
    switch (indexPath.section) {
        case 0:
            cell.textLabel.text = self.addChatTitle;
            break;
            
        case 1:
            cell.conversation = [self.conversationsArray objectAtIndex:indexPath.row];
            break;
    }
    
    return cell;
}

@end
