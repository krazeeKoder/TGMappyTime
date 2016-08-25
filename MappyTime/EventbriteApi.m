//
//  EventbriteApi.m
//  MappyTime
//
//  Created by Anthony Tulai on 2016-07-21.
//  Copyright © 2016 Anthony Tulai. All rights reserved.
//

#import "EventbriteApi.h"
#import <CoreLocation/CoreLocation.h>
#import <CoreLocation/CLPlacemark.h>
#import <MapKit/MapKit.h>
#import "Eventy.h"

@interface EventbriteApi ()

@property (strong, nonatomic) NSMutableArray *eventArray;
@end

@implementation EventbriteApi

+(void)fetchCategoryData:(void (^)(NSArray *))success failure:(void (^)(NSString *))failure {
    NSString *categoryDataURLString  = @"https://www.eventbriteapi.com/v3/categories/?token=RDVVDO7YFDE4XNRYRMNM";
    NSURL *categoryDataURL = [NSURL URLWithString:categoryDataURLString];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:categoryDataURL];
    NSURLSessionDataTask *gatherCategoryDataTask = [session dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error) {
            NSError *jsonParsingError;
            NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonParsingError];
            if (!jsonParsingError) {
                NSMutableArray *categoryArray = [NSMutableArray new];
                for (NSDictionary *categoryDictionary in jsonData[@"categories"]) {
                    Category *category = [Category new];
                    category.title = categoryDictionary[@"short_name_localized"];
                    category.categoryId = categoryDictionary[@"id"];
                    [categoryArray addObject:category];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                   success([categoryArray copy]);
                });
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                failure(error.localizedDescription);

            });
        }
        
    }];
    [gatherCategoryDataTask resume];
}
//https://www.eventbriteapi.com/v3/events/search/?location.within=20km&location.latitude=43.656603&location.longitude=-79.413194&start_date.range_end=2016-08-16T23%3A59%3A59&token=RDVVDO7YFDE4XNRYRMNM



+(void)fetchEventDataWithCategoryString:(NSString *)categoryString dateString:(NSString *)dateString latitude:(float)latitude longitude:(float)longitude pageNumber:(int)pageNumber eventArray:(NSArray *)eventArray success:(void (^)(NSArray *))success failure:(void (^)(NSString *))failure {
    
    NSString *eventDataURLString = @"";
//    NSString *eventDataURLString  = [[@"https://www.eventbriteapi.com/v3/events/search/?venue.city=Toronto&categories=" stringByAppendingString: categoryString] stringByAppendingString:@"&token=RDVVDO7YFDE4XNRYRMNM"];
    
    if (categoryString) {
        eventDataURLString = [NSString stringWithFormat: @"https://www.eventbriteapi.com/v3/events/search/?location.within=20km&location.latitude=%f&location.longitude=%f&page=%i&categories=%@&start_date.range_end=%@&expand=venue&token=RDVVDO7YFDE4XNRYRMNM",latitude,longitude,pageNumber,categoryString, dateString];
    } else {
        eventDataURLString = [NSString stringWithFormat: @"https://www.eventbriteapi.com/v3/events/search/?location.within=20km&location.latitude=%f&location.longitude=%f&page=%i&start_date.range_end=%@&expand=venue&token=RDVVDO7YFDE4XNRYRMNM",latitude,longitude,pageNumber,dateString];
    }
    pageNumber++;
    NSURL *eventDataURL = [NSURL URLWithString:eventDataURLString];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:eventDataURL];
    NSURLSessionDataTask *gatherEventDataTask = [session dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error) {
            NSError *jsonParsingError;
            NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonParsingError];
            if (!jsonParsingError) {
                //NSString *numberOfPagesString = jsonData[@"pagination"][@"page_count"];
                //int numberOfPages = [numberOfPagesString intValue];
                NSMutableArray *mutableEventArray = [NSMutableArray new];
                if (eventArray) {
                    mutableEventArray = [eventArray mutableCopy];
                }
                
                NSArray *emptyArrayCheck = jsonData[@"events"];
                if (!emptyArrayCheck || (emptyArrayCheck.count == 0)) /* == (id)[NSNull null]*/ {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        success(eventArray);
                        
                    });
                } else {
                    for (NSDictionary *eventDictionary in jsonData[@"events"]) {

                        Eventy *event = [Eventy new];
                        event.name = eventDictionary[@"name"][@"text"];
                         event.desc =   eventDictionary[@"description"][@"text"];
                        event._id = eventDictionary[@"id"];
                        event.url = eventDictionary[@"url"];
                        event.start_date = eventDictionary[@"start"][@"local"];
                        event.end_date = eventDictionary[@"end"][@"local"];
                        event.categoryId = eventDictionary[@"category_id"];
                        event.venueId = eventDictionary[@"venue_id"];
                        event.organizerId = eventDictionary[@"organizer_id"];
                        event.latitudeString = eventDictionary[@"venue"][@"address"][@"latitude"];
                        event.longitudeString = eventDictionary[@"venue"][@"address"][@"longitude"];
                        if (eventDictionary[@"venue_id"] != (id)[NSNull null] && eventDictionary[@"venue"][@"address"] != (id)[NSNull null] ) {
                            event.venue = [Venue new];
                            event.venue.streetAddress = eventDictionary[@"venue"][@"address"][@"address_1"];
                            event.venue.city = eventDictionary[@"venue"][@"address"][@"city"];
                            event.venue.postal_code = eventDictionary[@"venue"][@"address"][@"postal_code"];
                            event.venue.country= eventDictionary[@"venue"][@"address"][@"country"];
                            event.venue.latitude = eventDictionary[@"venue"][@"address"][@"latitude"];
                            event.venue.longitude = eventDictionary[@"venue"][@"address"][@"longitude"];
                            event.venue.localizedAddressDisplay = eventDictionary[@"venue"][@"address"][@"localized_address_display"];
                       }
                        [mutableEventArray addObject:event];
                    }
    //                if (numberOfPages == pageNumber) {
    //                    dispatch_async(dispatch_get_main_queue(), ^{
    //                        success([mutableEventArray copy]);
    //                    });
    //                } else {
                    [self fetchEventDataWithCategoryString:categoryString dateString:dateString latitude:latitude longitude:longitude pageNumber:pageNumber + 1 eventArray:[mutableEventArray copy] success:^(NSArray *successArray){
                        success(successArray);
                    } failure:^(NSString *failure) {
                        
                    }];
      
                }
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                failure(error.localizedDescription);
            });
        }
        
    }];
    [gatherEventDataTask resume];
}


@end
