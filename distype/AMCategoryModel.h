//
//  AMCategoryModel.h
//  distype
//
//  Created by amakushkin on 15.09.16.
//  Copyright © 2016 aacidov. All rights reserved.
//

#import <Realm/Realm.h>

@interface AMCategoryModel : RLMObject

@property (assign) NSTimeInterval categoryTimestamp;
@property (strong) NSString *categoryUniqId;
@property (strong) NSString *categoryTitle;


@end
