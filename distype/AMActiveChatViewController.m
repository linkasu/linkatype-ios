//
//  ActiveChatViewController.m
//  distype
//
//  Created by amakushkin on 13.09.16.
//  Copyright © 2016 aacidov. All rights reserved.
//

#import "AMChatMessageModel.h"
#import "AMChatTextInputView.h"
#import "AMActiveChatViewController.h"

@interface AMActiveChatViewController ()
<
UITableViewDelegate,
UITableViewDataSource,
AMChatTextInputViewDelegate
>

- (void)initialize;

@property (strong) NSString *cellIdentifier;
@property (strong, nonatomic) IBOutlet UITableView *chatTable;
@property (strong, nonatomic) IBOutlet UIScrollView *mainScrollView;
@property (strong) NSMutableArray<AMChatMessageModel*> *chatMessages;
@property (strong, nonatomic) IBOutlet AMChatTextInputView *chatMessageInput;

@end

@implementation AMActiveChatViewController

- (void)initialize {
    self.chatMessages = [[NSMutableArray alloc] init];
    self.cellIdentifier = [NSUUID UUID].UUIDString;
    
    self.chatTable.transform = CGAffineTransformMakeRotation(M_PI);
    self.chatTable.separatorColor = [UIColor clearColor];
    self.chatTable.delegate = self;
    self.chatTable.dataSource = self;
    [self.chatTable registerClass:[UITableViewCell class]
           forCellReuseIdentifier:self.cellIdentifier];
  
    self.chatMessageInput.delegate = self;
    
#warning Need to delete this code after implementing ChatsList
    /*
     START
     */
    self.conversationUniqId = [NSUUID UUID].UUIDString;
    
    RLMResults *resultsConversation = [AMChatMessageModel allObjects];
    
    for (AMChatMessageModel *obj in resultsConversation) {
        [self.chatMessages insertObject:obj atIndex:0];
    }
    /*
     END
     */
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initialize];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setConversationUniqId:(NSString *)conversationUniqId {
    if (self.chatMessages == nil) {
        self.chatMessages = [[NSMutableArray alloc] init];
    } else {
        [self.chatMessages removeAllObjects];
    }
    
    _conversationUniqId = conversationUniqId;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"conversationUniqId == %@", conversationUniqId];
    RLMResults *resultsConversation = [AMChatMessageModel objectsWithPredicate:predicate];
    
    for (AMChatMessageModel *obj in resultsConversation) {
        [self.chatMessages insertObject:obj atIndex:0];
    }
}

#pragma mark - Keyboard Events

- (void)keyboardWillShow:(NSNotification *)notification {
    CGRect keyboardFrame = [[[notification userInfo] valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyboardAppearingDuration = [[[notification userInfo] valueForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGPoint scrollOffset = CGPointMake(self.mainScrollView.contentOffset.x, keyboardFrame.size.height - self.chatMessageInput.frame.size.height + 1);

    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:keyboardAppearingDuration animations:^{
        __strong typeof(weakSelf) self = weakSelf;
        self.mainScrollView.contentOffset = scrollOffset;
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    CGFloat keyboardAppearingDuration = [[[notification userInfo] valueForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGPoint offset = CGPointZero;
    
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:keyboardAppearingDuration animations:^{
        __strong typeof(weakSelf) self = weakSelf;
        self.mainScrollView.contentOffset = offset;
    }];
}

#pragma mark - AMChatTextInputViewDelegate

- (void)needToSendMessage:(NSString*)message {
    if (message == nil
        || [message isEqualToString:@" "] == YES
        || [message isEqualToString:@""] == YES) {
        return;
    }
    
    AMChatMessageModel *msg = [[AMChatMessageModel alloc] init];
    
    msg.chatMessage = message;
    msg.conversationUniqId = self.conversationUniqId;
    msg.chatMessageTimestamp = [[NSDate date] timeIntervalSince1970];
    
    [self.chatMessages insertObject:msg atIndex:0];
    [self.chatTable insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:YES];
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    [realm addObject:msg];
    [realm commitWriteTransaction];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.chatMessages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier forIndexPath:indexPath];
    
    cell.textLabel.text = [self.chatMessages objectAtIndex:indexPath.row].chatMessage;
    cell.transform = CGAffineTransformMakeRotation(M_PI);
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    
    return cell;
}

@end
