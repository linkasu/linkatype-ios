//
//  AMWordCollectionViewCell.m
//  distype
//
//  Created by amakushkin on 21.09.16.
//  Copyright © 2016 aacidov. All rights reserved.
//

#import "AMWordCollectionViewCell.h"

@interface AMWordCollectionViewCell ()

@property (strong, nonatomic) IBOutlet UILabel *wordLabel;

@end

@implementation AMWordCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.layer.borderColor = [UIColor blackColor].CGColor;
    self.layer.borderWidth = 2;
    self.layer.cornerRadius = 10;
    
    self.wordLabel.numberOfLines = 1;
}

- (void)setWord:(AMChatMessageModel *)word {
    _word = word;
    
    self.wordLabel.text = word.text;
}

- (IBAction)deleteButtonTap:(UIButton *)sender {
    if ([self.delegate isKindOfClass:[NSNull class]] == NO
        && self.delegate != nil) {
        if ([self.delegate respondsToSelector:@selector(wordDeleteButtonPressed:)] == YES) {
            [self.delegate wordDeleteButtonPressed:self.word];
        }
    }
}

+ (NSString*)cellId {
    static NSString *cellId = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cellId = [NSUUID UUID].UUIDString;
    });
    
    return cellId;
}

@end
