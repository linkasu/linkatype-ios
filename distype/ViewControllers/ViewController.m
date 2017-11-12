//
//  ViewController.m
//  distype
//
//  Created by Иван Труфанов on 29.08.16.
//  Copyright © 2016 aacidov. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property(nonatomic, strong) IBOutlet UINavigationBar *navBar;
@property(nonatomic, strong) IBOutlet UIButton *sayButton;
@property(nonatomic, strong) IBOutlet UITextField *enterTextField;
@property(nonatomic, strong) IBOutlet UITableView *phrasesTableView;

@property(nonatomic, assign) NSInteger rowsCount;
@property(nonatomic, strong) UINavigationController *navController;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self resignFirstResponder];
    
    [self setupNavBar];
}

#pragma mark - Private

- (void)setupNavBar
{
    UINavigationItem *navigationItem = [UINavigationItem new];
    [navigationItem setRightBarButtonItem: [[UIBarButtonItem alloc] initWithTitle:@"Разговоры"
                                                                            style:UIBarButtonItemStylePlain
                                                                           target:self
                                                                           action:@selector(selectChat)]];

    [[self navBar] pushNavigationItem:navigationItem animated:NO];
}

- (void)selectChat
{
    
}

@end
