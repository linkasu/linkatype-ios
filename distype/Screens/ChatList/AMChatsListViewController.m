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
#import "AMChatTableViewCell.h"
#import "AMChatMessageModel.h"

@interface AMChatsListViewController ()

- (BOOL)isTextEmpty:(NSString*)text;

@property (strong) NSString *addChatTitle;
@property (strong) RLMResults *conversationsArray;

@end

@implementation AMChatsListViewController

static CGFloat headerHeight = 50.;

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
    
    if (text == nil || [text isEqualToString:@""] == YES) {
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
        && [sender isKindOfClass:[AMChatTableViewCell class]] == YES)
    {
        AMActiveChatViewController *controller = (AMActiveChatViewController*)segue.destinationViewController;
        AMChatTableViewCell *cell = (AMChatTableViewCell*)sender;
        
        controller.conversation = cell.conversation;
    }
}

#pragma mark - Private

- (void)dialogShowCreateNewChat
{
    __weak typeof(self) weakSelf = self;
    
    void (^createChatBlock)(LGAlertView *, NSString *, NSUInteger) = ^(LGAlertView *alertView,
                                                                       NSString *title,
                                                                       NSUInteger index)
    {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        UITextField *textField = [alertView.textFieldsArray objectAtIndex:index];
        NSString *chatTitle = textField.text;
        if ([strongSelf isTextEmpty:chatTitle] == YES) {
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
            
            strongSelf.conversationsArray = [AMConversationModel allObjects];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                __weak typeof(self) weakSelf = strongSelf;
                [weakSelf.tableView reloadData];
            });
        }
        else
        {
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
    };
    
    LGAlertView *alertView = [[LGAlertView alloc] initWithTextFieldsAndTitle:@"Create new chat"
                                                                     message:@"Enter name of new chat"
                                                          numberOfTextFields:1
                                                      textFieldsSetupHandler:nil
                                                                buttonTitles:@[@"Ok"]
                                                           cancelButtonTitle:@"Cancel"
                                                      destructiveButtonTitle:nil
                                                               actionHandler:createChatBlock
                                                               cancelHandler:nil
                                                          destructiveHandler:nil];
    alertView.cancelOnTouch = NO;
    [alertView showAnimated:YES completionHandler:nil];
}

#pragma mark - UITableViewDelegate
#pragma mark - UITableViewDataSource

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
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
    return YES;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, headerHeight)];
    UILabel *text = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 200, headerHeight)];
    text.text = self.addChatTitle;
    header.backgroundColor = [UIColor lightTextColor];
    [header addSubview:text];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dialogShowCreateNewChat)];
    [header addGestureRecognizer:tap];
    
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return headerHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.conversationsArray.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AMChatTableViewCell *cell = (AMChatTableViewCell*)[tableView dequeueReusableCellWithIdentifier:[AMChatTableViewCell cellId] forIndexPath:indexPath];

    cell.conversation = [self.conversationsArray objectAtIndex:indexPath.row];

    return cell;
}

@end
