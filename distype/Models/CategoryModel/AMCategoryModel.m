//
//  AMCategoryModel.m
//  distype
//
//  Created by amakushkin on 15.09.16.
//  Copyright © 2016 aacidov. All rights reserved.
//

#import "AMCategoryModel.h"

@implementation AMCategoryModel

- (instancetype)init
{
    self = [super init];
    
    if (self != nil)
    {
        self.categoryTimestamp = [[NSDate date] timeIntervalSince1970];
        self.categoryUniqId = [NSUUID UUID].UUIDString;
    }
    
    return self;
}

@end
