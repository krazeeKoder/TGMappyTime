//
//  Category.h
//  MappyTime
//
//  Created by Anthony Tulai on 2016-07-21.
//  Copyright © 2016 Anthony Tulai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Category : NSObject

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *categoryId;
@property (assign, nonatomic) BOOL isFavourite;

@end
