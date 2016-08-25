//
//  EventbriteApi.h
//  MappyTime
//
//  Created by Anthony Tulai on 2016-07-21.
//  Copyright © 2016 Anthony Tulai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Category.h"

@interface EventbriteApi : NSObject


+(void)fetchCategoryData:(void (^)(NSArray *))success failure:(void (^)(NSString *))failure;
+(void)fetchEventDataWithCategoryString:(NSString *)categoryString dateString:(NSString *)dateString latitude:(float)latitude longitude:(float)longitude pageNumber:(int)pageNumber eventArray:(NSArray *)eventArray success:(void (^)(NSArray *))success failure:(void (^)(NSString *))failure;

@end
