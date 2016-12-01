//
//  AMWordCollectionViewCell.h
//  distype
//
//  Created by amakushkin on 21.09.16.
//  Copyright © 2016 aacidov. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AMChatMessageModel.h"

@protocol AMWordCollectionViewCellDelegate <NSObject>

- (void)wordDeleteButtonPressed:(AMChatMessageModel*)message;

@end

@interface AMWordCollectionViewCell : UICollectionViewCell

+ (NSString*)cellId;

@property (weak) id<AMWordCollectionViewCellDelegate> delegate;
@property (strong, nonatomic) AMChatMessageModel *word;

@end
