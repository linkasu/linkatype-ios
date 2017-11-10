//
//  AMChooseCategoryViewController.h
//  distype
//
//  Created by Mike Kholomeev on 11/10/17.
//  Copyright © 2017 aacidov. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AMChooseCategoryDelegateProtocol<NSObject>

- (void)didChooseCategoryName:(NSString *)categoryName;
- (void)deleteCategoryWithTitle:(NSString *)categoryName;

@end


@interface AMChooseCategoryViewController : UIViewController

@property (nonatomic, assign) CGFloat parrentWidth;
@property (nonatomic, weak) id<AMChooseCategoryDelegateProtocol> delegate;

- (void)setCategories:(NSArray <NSString *> *)categories;

@end
