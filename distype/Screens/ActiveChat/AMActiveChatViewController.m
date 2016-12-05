//
//  ActiveChatViewController.m
//  distype
//
//  Created by amakushkin on 13.09.16.
//  Copyright © 2016 aacidov. All rights reserved.
//

#import "LGAlertView.h"

#import "AMDBController.h"
#import "AMCategoryModel.h"
#import "AMChatMessageModel.h"
#import "AMConversationModel.h"
#import "AMChatTextInputView.h"
#import "AMWordCollectionViewCell.h"
#import "AMActiveChatViewController.h"

@import DropdownMenu;


@interface AMActiveChatViewController ()
<
UITableViewDelegate,
UITableViewDataSource,
UIPickerViewDelegate,
UIPickerViewDataSource,
UICollectionViewDelegate,
UICollectionViewDataSource,
AMChatTextInputViewDelegate,
AMWordCollectionViewCellDelegate,
DropdownMenuDelegate
>

- (void)initialize;
- (void)hideWordsKeyboard;
- (BOOL)isTextEmpty:(NSString*)text;
- (void)showWordsKeyboardForCategory:(NSString*)categoryUniqId;

@property (nonatomic, strong) NSString *cellIdentifier;
@property (nonatomic, assign) BOOL isNonStandartKeyboardUsed;
@property (nonatomic, assign) NSInteger selectedRow;

@property (nonatomic, strong) RLMResults <AMChatMessageModel *> *wordsForCategory;
@property (nonatomic, strong) AMChatMessageModel *temporaryMsg;
@property (nonatomic, strong) RLMResults <AMCategoryModel *> *categoryQueryResult;
@property (nonatomic, strong) NSMutableArray<AMChatMessageModel*> *chatMessages;

@property (nonatomic, strong) LGAlertView *pickerActionSheet;
@property (nonatomic, strong) UICollectionView *categoryWordCollection;
@property (nonatomic, strong, nonatomic) DropdownMenu *menuView;

@property (strong, nonatomic) IBOutlet UITableView *chatTable;
@property (strong, nonatomic) IBOutlet UIScrollView *mainScrollView;
@property (strong, nonatomic) IBOutlet AMChatTextInputView *chatMessageInput;

@end

@implementation AMActiveChatViewController

- (void)initialize {
    self.selectedRow = 0;
    self.title = self.chat.conversationTitle;
    
    self.chatMessages = [[NSMutableArray alloc] init];
    self.cellIdentifier = [NSUUID UUID].UUIDString;
    
    self.chatTable.transform = CGAffineTransformMakeRotation(M_PI);
    self.chatTable.separatorColor = [UIColor clearColor];
    self.chatTable.delegate = self;
    self.chatTable.dataSource = self;
    [self.chatTable registerClass:[UITableViewCell class]
           forCellReuseIdentifier:self.cellIdentifier];
    
    self.chatMessageInput.delegate = self;
    
    CGRect rectCollection = CGRectMake(0,
                                       [UIScreen mainScreen].bounds.size.height + 10,
                                       [UIScreen mainScreen].bounds.size.width,
                                       [UIScreen mainScreen].bounds.size.height / 4);
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    flowLayout.estimatedItemSize = CGSizeMake(rectCollection.size.width / 3, rectCollection.size.height / 3);
    self.categoryWordCollection = [[UICollectionView alloc] initWithFrame:rectCollection collectionViewLayout:flowLayout];
    [self.categoryWordCollection registerNib:[UINib nibWithNibName:@"AMWordCollectionViewCell" bundle:nil]
                  forCellWithReuseIdentifier:[AMWordCollectionViewCell cellId]];
    self.categoryWordCollection.dataSource = self;
    self.categoryWordCollection.delegate = self;
    self.categoryWordCollection.backgroundColor = [UIColor whiteColor];
    
    RLMResults <AMChatMessageModel *> *resultsConversation = [self.db allWordsForChatID:self.chat.conversationUniqId];
    
    for (AMChatMessageModel *obj in resultsConversation) {
        [self.chatMessages insertObject:obj atIndex:0];
    }
    
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

- (void)hideWordsKeyboard {
    self.isNonStandartKeyboardUsed = NO;
    self.chatMessageInput.hidden = NO;
    self.wordsForCategory = nil;
    
    [self.categoryWordCollection reloadSections:[NSIndexSet indexSetWithIndex:0]];
    
    CGPoint offset = CGPointZero;
    
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.5f animations:^{
        __strong typeof(weakSelf) self = weakSelf;
        self.mainScrollView.contentOffset = offset;
        self.categoryWordCollection.frame = CGRectMake(self.categoryWordCollection.frame.origin.x,
                                                       [UIScreen mainScreen].bounds.size.height + self.categoryWordCollection.frame.size.height,
                                                       self.categoryWordCollection.frame.size.width,
                                                       self.categoryWordCollection.frame.size.height);
    } completion:^(BOOL finished) {
        __strong typeof(weakSelf) self = weakSelf;
        [self.categoryWordCollection removeFromSuperview];
    }];
}

- (void)showWordsKeyboardForCategory:(NSString*)categoryUniqId {
    self.chatMessageInput.hidden = YES;
    
    self.wordsForCategory = [self.db allWordsForCategoryID:categoryUniqId];
    
    if (self.wordsForCategory.count > 0) {
        self.isNonStandartKeyboardUsed = YES;
        
        [self.view addSubview:self.categoryWordCollection];
        CGPoint scrollOffset = CGPointMake(self.mainScrollView.contentOffset.x,
                                           self.categoryWordCollection.frame.size.height);
        
        __weak typeof(self) weakSelf = self;
        [UIView animateWithDuration:0.5f animations:^{
            __strong typeof(weakSelf) self = weakSelf;
            self.mainScrollView.contentOffset = scrollOffset;
            self.categoryWordCollection.frame = CGRectMake(self.categoryWordCollection.frame.origin.x,
                                                           [UIScreen mainScreen].bounds.size.height - self.categoryWordCollection.frame.size.height - self.chatMessageInput.frame.size.height,
                                                           self.categoryWordCollection.frame.size.width,
                                                           self.categoryWordCollection.frame.size.height);
        } completion:^(BOOL finished) {
            __strong typeof(weakSelf) self = weakSelf;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.categoryWordCollection reloadData];
            });
        }];
    } else {
        self.chatMessageInput.hidden = NO;
        self.isNonStandartKeyboardUsed = NO;
        
        LGAlertView *alertView = [[LGAlertView alloc] initWithTitle:@"Error"
                                                            message:@"Words category doesn't contain any words yet."
                                                              style:LGAlertViewStyleAlert
                                                       buttonTitles:@[@"Ok"]
                                                  cancelButtonTitle:nil
                                             destructiveButtonTitle:nil];
        alertView.cancelOnTouch = NO;
        
        [alertView showAnimated:YES completionHandler:nil];
    }
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

- (void)showMenu
{
    self.categoryQueryResult = [self.db allCategories];
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:[self.categoryQueryResult count] + 1];
    
    DropdownItem *item = [[DropdownItem alloc] initWithImage:nil
                                                       title:@"Standart keyboard"
                                                       style:DropdownItemStyleDefault
                                              accessoryImage:nil];
    [items addObject:item];
    
    for (AMCategoryModel *category in self.categoryQueryResult)
    {
        item = [[DropdownItem alloc] initWithImage:nil
                                             title:category.categoryTitle
                                             style:DropdownItemStyleDefault
                                    accessoryImage:nil];
        [items addObject:item];
    }
    
    self.menuView = [[DropdownMenu alloc] initWithNavigationController:self.navigationController
                                                                 items:items
                                                           selectedRow:self.selectedRow];
    self.menuView.delegate = self;
    [self.menuView showMenuWithIsOnNavigaitionView:YES];
}


#pragma mark - Button events

- (IBAction)changeKeyboardAction:(UIBarButtonItem *)sender
{
//    if (self.isNonStandartKeyboardUsed == YES)
//    {
//        [self hideWordsKeyboard];
//    } else
//    {
        [self showMenu];
//    }
}

#pragma mark - Keyboard Events

- (void)keyboardWillShow:(NSNotification *)notification {
    CGRect keyboardFrame = [[[notification userInfo] valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyboardAppearingDuration = [[[notification userInfo] valueForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGPoint scrollOffset = CGPointMake(self.mainScrollView.contentOffset.x,
                                       keyboardFrame.size.height);
    
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

#pragma mark - AMWordViewDelegate

- (void)wordDeleteButtonPressed:(AMChatMessageModel*)message {
    [self.db deleteWord:message];
    
    self.wordsForCategory = [self.db allWordsForCategoryID:message.categoryUniqId];
    
    if (self.wordsForCategory.count == 0) {
        [self hideWordsKeyboard];
    } else {
        [self.categoryWordCollection reloadSections:[NSIndexSet indexSetWithIndex:0]];
    }
}

#pragma mark - AMChatTextInputViewDelegate

- (void)needToAddToCategory:(NSString*)message {
    [self.chatMessageInput hideKeyboard];
    
    __weak typeof(self) weakSelf = self;
    void (^addMessageToCategoryBlock)(LGAlertView *, NSString *, NSUInteger) = ^(LGAlertView *alertView,
                                                                                 NSString *title,
                                                                                 NSUInteger index)
    {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        UITextField *textField = [alertView.textFieldsArray objectAtIndex:index];
        if ([strongSelf isTextEmpty:textField.text] == YES
            || [strongSelf isTextEmpty:message] == YES) {
            return;
        }
        
        strongSelf.temporaryMsg = [AMChatMessageModel new];
        strongSelf.temporaryMsg.text = message;
        strongSelf.temporaryMsg.conversationUniqId = strongSelf.chat.conversationUniqId;
        
        AMCategoryModel *category = [strongSelf.db categoryWithTitle:textField.text];
        strongSelf.temporaryMsg.categoryUniqId = category.categoryUniqId;

        [strongSelf.db addMessage:strongSelf.temporaryMsg];
    };
    
    LGAlertView *alertView = [[LGAlertView alloc] initWithTextFieldsAndTitle:@"Add word"
                                                                     message:@"Type name of word category"
                                                          numberOfTextFields:1
                                                      textFieldsSetupHandler:nil
                                                                buttonTitles:@[@"Add"]
                                                           cancelButtonTitle:@"Cancel"
                                                      destructiveButtonTitle:nil
                                                               actionHandler:addMessageToCategoryBlock
                                                               cancelHandler:nil
                                                          destructiveHandler:nil];
    alertView.cancelOnTouch = NO;
    
    [alertView showAnimated:YES completionHandler:nil];
}

- (void)needToSendMessage:(NSString*)text {
    if ([self isTextEmpty:text] == YES) {
        return;
    }
    
    BOOL isNeedToAddToRealm = NO;
    AMChatMessageModel *msg = nil;
    
    if ([self.temporaryMsg.text isEqualToString:text] == YES) {
        msg = self.temporaryMsg;
        self.temporaryMsg = nil;
        isNeedToAddToRealm = NO;
    } else {
        msg = [AMChatMessageModel new];
        msg.text = text;
        msg.conversationUniqId = self.chat.conversationUniqId;
        isNeedToAddToRealm = YES;
    }
    
    [self.chatMessages insertObject:msg atIndex:0];
    [self.chatTable insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:YES];
    
    if (isNeedToAddToRealm == YES)
    {
        [self.db addMessage:msg];
    }
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    AMWordCollectionViewCell *cell = (AMWordCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
    
    [UIView animateWithDuration:0.15f animations:^{
        cell.backgroundColor = [UIColor lightGrayColor];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.15f animations:^{
            cell.backgroundColor = [UIColor clearColor];
        }];
    }];
    
    [self.chatMessages insertObject:cell.word atIndex:0];
    [self.chatTable reloadData];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.wordsForCategory.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    AMWordCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[AMWordCollectionViewCell cellId]
                                                                               forIndexPath:indexPath];
    cell.word = [self.wordsForCategory objectAtIndex:indexPath.item];
    cell.delegate = self;
    
    return cell;
}

#pragma mark - UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    AMCategoryModel *categoryModel = [self.categoryQueryResult objectAtIndex:row];
    
    return categoryModel.categoryTitle;
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.categoryQueryResult.count;
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
    
    cell.textLabel.text = [self.chatMessages objectAtIndex:indexPath.row].text;
    cell.transform = CGAffineTransformMakeRotation(M_PI);
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    
    return cell;
}

#pragma mark - DropdownMenuDelegate
- (UITableViewCell * _Nullable)dropdownMenu:(DropdownMenu * _Nonnull)dropdownMenu cellForRowAt:(NSIndexPath * _Nonnull)indexPath
{
    return [[dropdownMenu tableView] cellForRowAtIndexPath:indexPath];
}

- (void)dropdownMenu:(DropdownMenu * _Nonnull)dropdownMenu didSelectRowAt:(NSIndexPath * _Nonnull)indexPath
{
    NSInteger row = [indexPath row];
    self.selectedRow = row;
    
    if (row == 0)
    {
        [self hideWordsKeyboard];
    }
    else
    {
        // we added StandertKeyboard row at Table, so correct index og category in arra would be  n-1
        AMCategoryModel *category = [self.categoryQueryResult objectAtIndex:row - 1];
        [self showWordsKeyboardForCategory:category.categoryUniqId];
    }
}

- (void)dropdownMenuCancel:(DropdownMenu * _Nonnull)dropdownMenu
{
    
}

@end
