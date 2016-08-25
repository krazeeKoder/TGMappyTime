//
//  Eventy.h
//  MappyTime
//
//  Created by Anthony Tulai on 2016-08-02.
//  Copyright © 2016 Anthony Tulai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Venue.h"

@interface Eventy : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *desc;
@property (strong, nonatomic) NSString *_id;
@property (strong, nonatomic) NSString *url;
@property (strong, nonatomic) NSString *start_date;
@property (strong, nonatomic) NSString *end_date;
@property (strong, nonatomic) NSString *categoryId;
@property (strong, nonatomic) NSString *venueId;
@property (strong, nonatomic) NSString *organizerId;
@property (strong, nonatomic) NSString *latitudeString;
@property (strong, nonatomic) NSString *longitudeString;
@property (strong, nonatomic) Venue   *venue;



-(id)init;
@end
