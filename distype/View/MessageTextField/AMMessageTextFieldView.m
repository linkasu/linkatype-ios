//
//  AMMessageTextFieldView.m
//  distype
//
//  Created by amakushkin on 14.09.16.
//  Copyright © 2016 aacidov. All rights reserved.
//

#import "AMMessageTextFieldView.h"

@implementation AMMessageTextFieldView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    self.layer.cornerRadius = 8;
    self.layer.borderWidth = 1;
    
    return self;
}

- (CGRect)textRectForBounds:(CGRect)bounds {
    return CGRectInset(bounds, self.insetX, self.insetY);
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    return CGRectInset(bounds, self.insetX, self.insetY);
}

@end
