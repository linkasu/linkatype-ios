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
#import "MKDropdownMenu.h"

//#import <TBDropdownMenu/TBDropdownMenu-Swift.h>
//@import TBDropdownMenu;
#import "AMChooseCategoryViewController.h"

typedef NS_ENUM(NSUInteger, AMMenuType) {
    MenuTypeUpper,
    MenuTypeAllert,
};

@interface AMActiveChatViewController ()
<
UITableViewDelegate,
UITableViewDataSource,
UICollectionViewDelegate,
UICollectionViewDataSource,
AMChatTextInputViewDelegate,
AMWordCollectionViewCellDelegate,
MKDropdownMenuDelegate,
MKDropdownMenuDataSource,
AMChooseCategoryDelegateProtocol,
UIPopoverPresentationControllerDelegate
>

- (void)initialize;
- (void)hideWordsKeyboard;
- (BOOL)isTextEmpty:(NSString*)text;
- (void)showWordsKeyboardForCategory:(NSString*)categoryUniqId;

@property (nonatomic, strong) NSString *cellIdentifier;
@property (nonatomic, assign) BOOL isNonStandartKeyboardUsed;
@property (nonatomic, assign) NSInteger selectedUpperMenuRow;
@property (nonatomic, assign) NSInteger selectedAllertMenuRow;
@property (nonatomic, assign) AMMenuType menuType;
@property (nonatomic, strong) NSString *addedToCategoryMessage;

@property (nonatomic, strong) RLMResults <AMChatMessageModel *> *wordsForCategory;
@property (nonatomic, strong) AMChatMessageModel *temporaryMsg;
@property (nonatomic, strong) RLMResults <AMCategoryModel *> *categoryQueryResult;
@property (nonatomic, strong) NSMutableArray<AMChatMessageModel*> *chatMessages;

@property (nonatomic, strong) LGAlertView *pickerActionSheet;
@property (nonatomic, strong) UICollectionView *categoryWordCollection;

@property (nonatomic, strong) IBOutlet MKDropdownMenu *menuView;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *menuContainerBarItem;
@property (strong, nonatomic) IBOutlet UITableView *chatTable;
@property (strong, nonatomic) IBOutlet UIScrollView *mainScrollView;
@property (strong, nonatomic) IBOutlet AMChatTextInputView *chatMessageInput;

@end

@implementation AMActiveChatViewController

- (void)initialize {
    self.selectedUpperMenuRow = 0;
    self.title = self.chat.conversationTitle;
    self.categoryQueryResult = [self.db allCategories];
    
    [self.menuView setUseFullScreenWidth:YES];
    [self.menuView setDisclosureIndicatorImage:[UIImage new]];
    [self.menuView setDropdownBouncesScroll:YES];
    [self.menuView setBackgroundDimmingOpacity:0.1];
    [self.menuView closeAllComponentsAnimated:NO];
    
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

-(void)viewWillAppear:(BOOL)animated
{
    [self.menuView closeAllComponentsAnimated:NO];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.menuView closeAllComponentsAnimated:NO];
    [super viewWillDisappear:animated];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)hideWordsKeyboard {
    self.isNonStandartKeyboardUsed = NO;
    self.chatMessageInput.hidden = NO;
    self.wordsForCategory = nil;
    self.selectedUpperMenuRow = 0;
    
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

- (void)reloadUpperMenu
{
    self.categoryQueryResult = [self.db allCategories];

    [self.menuView reloadAllComponents];

    self.menuType = MenuTypeUpper;
}

- (void)showCategoryChoiceForMessage:(NSString *)message
{
    self.addedToCategoryMessage = message;

    NSString *storyboardName = NSStringFromClass([AMChooseCategoryViewController class]);
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:nil];
    AMChooseCategoryViewController *vc = [storyboard instantiateInitialViewController];

    [vc setCategories:[self categoriesNames]];
    [vc setDelegate: self];

    vc.parrentWidth = self.view.bounds.size.width;

    vc.modalPresentationStyle = UIModalPresentationPopover;
    vc.popoverPresentationController.barButtonItem = self.menuContainerBarItem;
    vc.popoverPresentationController.permittedArrowDirections = 0;
    vc.popoverPresentationController.delegate = self;

    [self presentViewController:vc animated:YES completion:nil];}

- (void)performAddText:(NSString *)text toCategory:(AMCategoryModel *)category
{
    if ([self isTextEmpty:text])
    {
        return;
    }
    
    self.temporaryMsg = [AMChatMessageModel new];
    self.temporaryMsg.text = text;
    self.temporaryMsg.conversationUniqId = self.chat.conversationUniqId;
    self.temporaryMsg.categoryUniqId = category.categoryUniqId;
    
    [self.db addMessage:self.temporaryMsg];
}

#pragma mark - UIStackView Buttons action
- (void)touchCategoryButton:(UILabel *)sender
{
    AMCategoryModel *category = [self.db categoryWithTitle:sender.text];
    [self performAddText:self.addedToCategoryMessage toCategory:category];
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

- (void)needToAddToCategory:(NSString*)message
{
    [self.chatMessageInput hideKeyboard];
    
    [self showCategoryChoiceForMessage:message];
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

#pragma mark - MKDropdownMenuDatasource

- (NSInteger)numberOfComponentsInDropdownMenu:(MKDropdownMenu *)dropdownMenu
{
    return 1;
}

- (NSInteger)dropdownMenu:(MKDropdownMenu *)dropdownMenu numberOfRowsInComponent:(NSInteger)component
{
    // we added row "StandartKeyboard" at Table, so correct index of category in array would be  n-1
    return [self.categoryQueryResult count] + 1;
}

- (CGFloat)dropdownMenu:(MKDropdownMenu *)dropdownMenu rowHeightForComponent:(NSInteger)component {
    return 50;
}

#pragma mark - MKDropdownMenuDelegate

- (NSString *)dropdownMenu:(MKDropdownMenu *)dropdownMenu titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (row == 0)
    {
        return @"StandartKeyboard";
    }
    else
    {
    // we added row "StandartKeyboard" at Table, so correct index of category in array would be  n-1
    AMCategoryModel *category = [self.categoryQueryResult objectAtIndex:row - 1];
        return category.categoryTitle;
    }
}

- (UIColor *)dropdownMenu:(MKDropdownMenu *)dropdownMenu backgroundColorForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [UIColor whiteColor];
}

- (UIColor *)dropdownMenu:(MKDropdownMenu *)dropdownMenu backgroundColorForHighlightedRowsInComponent:(NSInteger)component {
    return [UIColor colorWithWhite:0.8 alpha:0.5];
}

- (void)dropdownMenu:(MKDropdownMenu *)dropdownMenu didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.selectedUpperMenuRow = row;
    
    if (row == 0)
    {
        [self hideWordsKeyboard];
    }
    else
    {
        // we added row "StandartKeyboard" at Table, so correct index of category in array would be  n-1
        AMCategoryModel *category = [self.categoryQueryResult objectAtIndex:row - 1];
        [self showWordsKeyboardForCategory:category.categoryUniqId];
    }
    
    delay(0.15, ^{
        [dropdownMenu closeAllComponentsAnimated:YES];
    });
}

#pragma mark - AMChooseCategoryDelegateProtocol

- (void)didChooseCategoryName:(NSString *)categoryName
{
    AMCategoryModel *category = [self.db categoryWithTitle:categoryName];
    [self performAddText:self.addedToCategoryMessage toCategory:category];
    [self reloadUpperMenu];
}

- (void)deleteCategoryWithTitle:(NSString *)categoryName
{
    AMCategoryModel *category = [self.db categoryWithTitle:categoryName];
    [self.db deleteCategory:category];
    [self reloadUpperMenu];
}

#pragma mark - UIPopoverPresentationControllerDelegate

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller
{
    return UIModalPresentationNone;
}

#pragma mark - Private

static inline void delay(NSTimeInterval delay, dispatch_block_t block) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), block);
}

- (NSArray <NSString *> *)categoriesNames
{
    self.categoryQueryResult = [self.db allCategories];
    NSMutableArray <NSString *> *names = [NSMutableArray array];
    
    for (AMCategoryModel *category in self.categoryQueryResult) {
        [names addObject:[category categoryTitle]];
    }

    return names;
}

@end
