//
//  AMChatsListViewController.m
//  distype
//
//  Created by amakushkin on 13.09.16.
//  Copyright © 2016 aacidov. All rights reserved.
//

#import "LGAlertView.h"

#import "AMDBController.h"
#import "AMActiveChatViewController.h"
#import "AMChatsListViewController.h"
#import "AMConversationModel.h"
#import "AMChatTableViewCell.h"
#import "AMChatMessageModel.h"

@interface AMChatsListViewController ()

- (BOOL)isTextEmpty:(NSString*)text;

@property (nonatomic, strong) AMDBController *db;
@property (strong) NSString *addChatTitle;
@property (strong) RLMResults< AMConversationModel *> *chatArray;

@end

@implementation AMChatsListViewController

static CGFloat headerHeight = 50.;

- (void)setup {
    self.addChatTitle = @"ADD NEW CHAT";
    self.db = [AMDBController new];
    
    [self updateChatList];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
}

#pragma mark - Private
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

- (void)updateChatList
{
    self.chatArray =  self.db.allChats;
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
        NSIndexPath *indexPath = self.tableView.indexPathForSelectedRow;
        AMConversationModel *chat = [self.chatArray objectAtIndex:[indexPath row]];
        AMActiveChatViewController *controller = (AMActiveChatViewController*)segue.destinationViewController;
        
        controller.db = self.db;
        controller.chat = chat;
    }
}

#pragma mark - Private

- (void)dialogShowCreateNewChat
{
    __weak typeof(self) weakSelf = self;
    
    void (^createChatBlock)(LGAlertView *, NSUInteger, NSString *) = ^(LGAlertView *alertView,
                                                                       NSUInteger index,
                                                                       NSString *title)
    {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        UITextField *textField = [alertView.textFieldsArray objectAtIndex:index];
        NSString *chatTitle = textField.text;
        
        if ([strongSelf isTextEmpty:chatTitle] == YES) {
            return;
        }
        
        if ([strongSelf.db createChatWithTitle:chatTitle])
        {
            [strongSelf updateChatList];
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf.tableView reloadData];
            });
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
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        AMConversationModel *chat = [self.chatArray objectAtIndex:[indexPath row]];

        if ([self.db deleteChat:chat])
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
    return self.chatArray.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AMChatTableViewCell *cell = (AMChatTableViewCell*)[tableView dequeueReusableCellWithIdentifier:[AMChatTableViewCell cellId] forIndexPath:indexPath];

    cell.textLabel.text = [[self.chatArray objectAtIndex:indexPath.row] conversationTitle];

    return cell;
}

@end
