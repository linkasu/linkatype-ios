//
//  AMChatsListViewController.m
//  distype
//
//  Created by amakushkin on 13.09.16.
//  Copyright © 2016 aacidov. All rights reserved.
//

#import <LGAlertView.h>

#import "AMActiveChatViewController.h"
#import "AMChatsListViewController.h"
#import "AMConversationModel.h"

@interface AMChatsListViewController ()

- (BOOL)isTextEmpty:(NSString*)text;

@property (strong) NSString *cellId;
@property (strong) RLMResults *conversationsArray;

@end

@implementation AMChatsListViewController

- (void)initialize {
    self.cellId = [NSUUID UUID].UUIDString;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:self.cellId];
    
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellId forIndexPath:indexPath];
    
    switch (indexPath.section) {
        case 0:
            cell.textLabel.text = @"ADD NEW CHAT";
            break;
            
        case 1:
            cell.textLabel.text = ((AMConversationModel*)[self.conversationsArray objectAtIndex:indexPath.row]).conversationTitle;
            break;
    }
    
    return cell;
}

@end
