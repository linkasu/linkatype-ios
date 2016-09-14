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
@property (strong, nonatomic) IBOutlet AMChatTextInputView *chatMessageInput;

@end

@implementation AMActiveChatViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    [self initialize];
    
    return self;
}

- (void)initialize {
    self.chatMessages = [[NSMutableArray alloc] init];
    self.cellIdentifier = [NSUUID UUID].UUIDString;
    self.chatTable.separatorColor = [UIColor clearColor];
    self.chatMessageInput.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Keyboard Events

- (void)keyboardWillShow:(NSNotification *)notification {
    CGRect keyboardFrame = [[[notification userInfo] valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyboardAppearingDuration = [[[notification userInfo] valueForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGPoint offset = CGPointMake(self.mainScrollView.contentOffset.x, keyboardFrame.size.height - self.chatMessageInput.frame.size.height);
    
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:keyboardAppearingDuration animations:^{
        __strong typeof(weakSelf) self = weakSelf;
        self.mainScrollView.contentOffset = offset;
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
    
    return cell;
}

@end
