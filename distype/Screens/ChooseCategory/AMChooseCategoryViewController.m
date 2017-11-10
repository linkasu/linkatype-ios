//
//  AMChooseCategoryViewController.m
//  distype
//
//  Created by Mike Kholomeev on 11/10/17.
//  Copyright © 2017 aacidov. All rights reserved.
//

#import "AMChooseCategoryViewController.h"

@interface AMChooseCategoryViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *categoryTableView;
@property (weak, nonatomic) IBOutlet UITextField *categoryNameTextField;
@property (weak, nonatomic) IBOutlet UIButton *addCategoryButton;
@property (nonatomic, strong) NSArray <NSString *> *categories;

@end

@implementation AMChooseCategoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.editButtonItem.enabled = NO;
    
    CGFloat height = 400;
    CGSize preferredContentSize = CGSizeMake(self.parrentWidth - 30, height);
    self.preferredContentSize = preferredContentSize;
}

- (void)viewWillAppear:(BOOL)animated
{
//    [self.categoryTableView reloadData];
    [super viewWillAppear:animated];
}

#pragma mark - Actions
- (IBAction)cancelAction:(id)sender
{
    [self dismissSelf];
}

- (IBAction)addCategoryAction:(id)sender
{
    [[self delegate] didChooseCategoryName:[[self categoryNameTextField] text]];
    [self dismissSelf];
}

- (IBAction)textDidChangedAction:(id)sender
{
    self.editButtonItem.enabled = self.categoryNameTextField.text.length > 0;
}

#pragma mark - Public
- (void)setCategories:(NSArray <NSString *> *)categories
{
    _categories = categories;
}

#pragma mark - UITableViewDelegate, UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.categories.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"categoryCell"];
    cell.textLabel.text = [self.categories objectAtIndex:row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    [[self delegate] didChooseCategoryName:[self.categories objectAtIndex:row]];
    [self dismissSelf];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSString *title = [self.categories objectAtIndex:indexPath.row];
        NSMutableArray <NSString *> *array = [self.categories mutableCopy];
        [array removeObjectAtIndex:indexPath.row];
        self.categories = [array copy];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
        [self.delegate deleteCategoryWithTitle:title];
    }
}

#pragma mark - Private
- (void)dismissSelf
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
