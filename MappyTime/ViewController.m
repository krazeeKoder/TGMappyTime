//
//  ViewController.m
//  MappyTime
//
//  Created by Anthony Tulai on 2016-02-06.
//  Copyright © 2016 Anthony Tulai. All rights reserved.
//

#import "ViewController.h"
#import <AddressBookUI/AddressBookUI.h>
//#import <CoreLocation/CLGeocoder.h>
//#import <CoreLocation/CLPlacemark.h>
#import "Eventy.h"
//#import "SelectedDate.h"
//#import "Categ.h"
#import "GASection.h"
#import "GAScrollWheel.h"
#import "AppDelegate.h"
#import "FavouritesTableViewController.h"
//#import "SavedEvent.h"
#import "EventbriteApi.h"
#import "CategorySelectorTableViewController.h"



@import MapKit;
@import AddressBook;


@interface ViewController () <CLLocationManagerDelegate, MKMapViewDelegate, SGScrollWheelDelegate, UITableViewDataSource, UITableViewDelegate, CategorySelectorDelegate>

//@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) UIActivityIndicatorView *spinner;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) MKMapView *mapView;
@property (assign, nonatomic) BOOL initialLocationSet;
@property (strong, nonatomic) NSString *userLocationPostalCode;
@property (strong, nonatomic) NSString *eventsNearbyURLString;
@property (strong, nonatomic) NSMutableArray *eventsInMapView;
@property (strong, nonatomic) NSArray *events;
@property (strong, nonatomic) NSArray *selectedDatesArray;
@property (strong, nonatomic) NSArray *categoriesArray;
@property (strong, nonatomic) NSString *selectedDate;
@property (strong, nonatomic) NSDateComponents *addedDays;
@property (strong, nonatomic) NSMutableDictionary *datesDictionary;
@property (strong, nonatomic) GAScrollWheel *wheel;
@property (strong, nonatomic) UIView *wheelView;
@property (strong, nonatomic) UILabel *dateLabel;
@property NSInteger wheelValue;
@property (strong, nonatomic) NSDate *wheelLabelDate;
@property (assign, nonatomic) int completionCounter;
@property (strong, nonatomic) NSMutableArray *categoriesIDArray;
@property (strong, nonatomic) NSMutableArray *categoriesNameArray;
@property (strong, nonatomic) NSArray *categoryArray;
@property (strong, nonatomic) NSArray *selectedCategoryArray;
@property (strong, nonatomic) MKPointAnnotation *userLocation;
@property (strong, nonatomic) MKCircle *userRadius;
@property (assign, nonatomic) Boolean shouldRefreshFromFirstDay;
@property (assign, nonatomic) Boolean originalCategorySelectionComplete;

@end

@implementation ViewController

- (void)viewDidLoad {
//    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"isLoadingDone"]) {
//        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isLoadingDone"];
//    }
    [super viewDidLoad];
    [self prepareDataModel];
    [self prepareView];
    [self prepareMapView];
    [self getUserLocation];
    //[self populateCategories];
    //[self prepareContext];
    //[self getDateOffset]; // gets difference between todays date and last date logged in.
    //[self fetchSelectedDates];
//    //[self fetchCategories];
    //[self prepareAddedDaysComponents];
    
    
//    [self prepareLocationManager];
//    [self wheelAction];
}

-(void)viewWillAppear:(BOOL)animated {
    [self wheelAction];
}

#pragma  mark - Preparation 

-(void)populateCategories {
    [EventbriteApi fetchCategoryData:^(NSArray *categoryArray) {
        self.categoryArray = categoryArray;
        [self setCategoryPreferences:categoryArray];
    } failure:^(NSString *error) {
        NSLog(@"%@",error);
    }];
}

-(void)setCategoryPreferences:(NSArray *)categoryArray {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (![userDefaults objectForKey:@"categorypreference0"]) {
            [self presentCategorySelector: categoryArray];
    } else {
        NSMutableArray *selectedCategories = [NSMutableArray new];
        for (Category *category in categoryArray) {
            if ([category.categoryId isEqualToString:[userDefaults objectForKey:@"categorypreference0"]]||
                [category.categoryId isEqualToString:[userDefaults objectForKey:@"categorypreference1"]]||
                [category.categoryId isEqualToString:[userDefaults objectForKey:@"categorypreference2"]])
            {
                [selectedCategories addObject:category];
            }
        }
        self.selectedCategoryArray = [selectedCategories copy];
        [self getEventData];
    }
}
- (void)prepareView {
    [self prepareWheel];
    [self prepareDateLabel];
}

- (void)prepareWheel {
    self.wheelView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width * 0.4, self.view.frame.size.width * 0.4)];
    self.wheelView.center = CGPointMake(self.view.frame.size.width * 0.7, self.view.frame.size.height * 0.84);
    [self prepareSGScrollWheel];
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isLoadingDone"] == YES) {
        self.wheelView.alpha = 1.0;
    } else {
        self.wheelView.alpha = 0.4;
    }
   // self.wheelValue = 1;
}

- (void)prepareDateLabel {
    self.dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 110, 20)];
    self.dateLabel.center = CGPointMake(self.view.frame.size.width * 0.23, self.view.frame.size.height * 0.75);
//    self.label.backgroundColor = [UIColor colorWithRed:179/255.0 green:179/255.0 blue:179/255.0 alpha:1.0];
    self.dateLabel.backgroundColor = [UIColor blackColor];
    self.dateLabel.alpha = 0.5;
    [self.dateLabel setFont:[UIFont fontWithName:@"Helvetica Neue" size:16]];
    self.dateLabel.textColor = [UIColor whiteColor];
    self.dateLabel.textAlignment = NSTextAlignmentCenter;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    [dateFormatter setDateFormat:@"MMM dd, yyyy"];
    NSString *todaysDate = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0]];
    self.dateLabel.text = [NSString stringWithFormat:@"%@", todaysDate];
    NSLog(@"%@",self.dateLabel.text);
}

-(void)prepareGoToFavouritesButton {
    UIButton *goToFavouritesButton  = [[UIButton alloc] initWithFrame:CGRectMake(0,0, self.view.frame.size.width * 0.08, self.view.frame.size.width * 0.08)];
    goToFavouritesButton.center = CGPointMake(self.view.frame.size.width * 0.9, self.view.frame.size.height * 0.08);
//    [goToFavouritesButton setImage:[UIImage imageNamed:@"plus"] forState: UIControlStateNormal];
    UIImage *image = [UIImage imageNamed:@"plus"];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:goToFavouritesButton.bounds];
    imageView.image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [imageView setTintColor:[UIColor blackColor]];
    [imageView setAlpha:0.5];
    [goToFavouritesButton addSubview:imageView];
    
    [goToFavouritesButton addTarget:self action:@selector(openFavouritesTable) forControlEvents:UIControlEventTouchUpInside];
    [self.mapView addSubview:goToFavouritesButton];
}

- (IBAction) openFavouritesTable {
    FavouritesTableViewController *viewController = [[FavouritesTableViewController alloc]init];
    [self presentViewController: viewController animated:YES completion:^{
        nil;
    }];
};

-(void)prepareLegend {
    UITableView *legendTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 110, 105)];
    legendTableView.center = CGPointMake(self.view.frame.size.width * 0.23, self.view.frame.size.height * 0.87);
//    legendTableView.alpha = 0.7;
    legendTableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    legendTableView.backgroundColor = [UIColor clearColor];
    
    legendTableView.dataSource = self;
    legendTableView.delegate = self;
    
    [legendTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"legendCell"];
     
     [self.mapView addSubview:legendTableView];

     [legendTableView reloadData];
}

//- (void)prepareContext {
//    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//    self.managedObjectContext = appDelegate.managedObjectContext;
//}
- (void)prepareDataModel {
    self.shouldRefreshFromFirstDay = YES;
    [self prepareEventsInMapView];
}

- (void)prepareAddedDaysComponents {
    self.addedDays = [[NSDateComponents alloc] init];
    self.addedDays.day = 0;
}


- (void)prepareEventsInMapView {
    self.eventsInMapView = [[NSMutableArray alloc] init];
}

- (void)prepareMapView {
    self.mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.mapView.delegate = self;
    self.mapView.showsUserLocation = YES;
    [self.view addSubview:self.mapView];
    
    [self.mapView addSubview:self.wheelView];
    [self.mapView addSubview:self.dateLabel];
    //[self prepareLegend];
    [self prepareGoToFavouritesButton];

}

- (void)prepareLocationManager {
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.initialLocationSet = NO;
    
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        // Make the actual request. This will FAIL if you are missing the NSLocationWhenInUseUsageDescription key from the Info.plist
        [self.locationManager requestWhenInUseAuthorization];
    }
}


- (void)prepareSGScrollWheel {
    CGRect frame = self.wheelView.bounds;
    self.wheel = [[GAScrollWheel alloc] initWithFrame:frame delegate:self numberOfSections:8 image:nil];
    [self.wheel setupImage:[UIImage imageNamed:@"wheel"]];
    [self.wheelView addSubview:self.wheel];
}



#pragma mark - Updates

- (void)updateDateLabel {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM dd, yyyy"];
    NSString *wheelDate = [dateFormatter stringFromDate:self.wheelLabelDate];
    self.dateLabel.text = [NSString stringWithFormat:@"%@", wheelDate];
}




-(void)presentCategorySelector:(NSArray *)categoryArray {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CategorySelectorTableViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"categorySelector"];
    vc.categoryArray = categoryArray;
    vc.delegate = self;
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hyntSolved:) name:@"HYNT SOLVED" object:nil];
    //[self.navigationController setNavigationBarHidden:YES animated:YES];
    [self.navigationController pushViewController:vc animated:YES];
}

//-(void)fetchCategories {
//    NSError *error;
//    // Fetch object
//    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//    fetchRequest.includesSubentities = YES;
//    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Categ"
//                                              inManagedObjectContext:self.managedObjectContext];
//    [fetchRequest setEntity:entity];
//    
//    self.categoriesArray = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
//}




-(void)getEventsForDates:(NSString *)date
{
    [self.eventsInMapView removeAllObjects];
    [self.mapView removeAnnotations:self.mapView.annotations];
    for (Eventy *event in self.events) {
        NSString *dateString = [event.start_date substringToIndex:10];
        if ([dateString isEqualToString:date]) {
            MKPointAnnotation *eventAnnotation = [MKPointAnnotation new];
            eventAnnotation.title = event.name;
            eventAnnotation.coordinate = CLLocationCoordinate2DMake([event.venue.latitude doubleValue], [event.venue.longitude doubleValue]) ;
            
            [self.mapView addAnnotation:eventAnnotation];
            //eventAnnotation.
            //[self.eventsInMapView addObject:event];
        }
    }
//    for (SelectedDate* selectedDates in self.selectedDatesArray) {
//        if ([selectedDates.date isEqualToString: date]) {
////            NSLog(@"event date: %@", selectedDates.date);
//            [self.eventsInMapView addObjectsFromArray: [selectedDates.events allObjects]];
//        }
//    }
    //[self.mapView addAnnotations:self.eventsInMapView];
}

//
//-(void)createEvents {
//    NSMutableArray *results = [[NSMutableArray alloc]init];
//    
//    for (SelectedDate *date in self.selectedDatesArray) {
//        [results addObject:[date.events allObjects]];
//    }
//    self.eventsInMapView = [results copy];
//}


-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self showProgress:YES];
}

- (void)showProgress:(BOOL)show {
  //  self.spinner.hidden = !show;
    
    
}

-(NSString *)setupFirstDateString {
    NSDateComponents *dayComponent = [[NSDateComponents alloc] init];
    dayComponent.day = 1;
    
    NSCalendar *theCalendar = [NSCalendar currentCalendar];
    NSDate *nextDate = [theCalendar dateByAddingComponents:dayComponent toDate:[NSDate date] options:0];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *formattedDate = [dateFormatter stringFromDate:nextDate];
    return [formattedDate stringByAppendingString:@"T00%3A00%3A00"];
}

-(NSString *)setupDateStringForNext:(int)numberOfDays {
    
    NSCalendar *theCalendar = [NSCalendar currentCalendar];
    NSDateComponents *extraDays = [NSDateComponents new];
    extraDays.day = numberOfDays + 1;
    NSDate *date = [theCalendar dateByAddingComponents:extraDays toDate:[NSDate date] options:0];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *futureDate = [dateFormatter stringFromDate:date];
    
    return [futureDate stringByAppendingString:@"T00%3A00%3A00"];
}



-(NSString *)setupCategoryString {
    if (self.selectedCategoryArray) {
        Category *category1 = self.selectedCategoryArray[0];
        NSString *categoryString = category1.categoryId;
        
        for (int i = 1; i < self.selectedCategoryArray.count; i++) {
            Category *nextCategory = self.selectedCategoryArray[i];
            categoryString = [[categoryString stringByAppendingString:@"%2c"] stringByAppendingString:nextCategory.categoryId];
        }
        return categoryString;
    }
    return nil;
    
}

//-(NSString *)setupUrlString {
//    NSString *dateString = [self setupDateString];
//    NSString *categoryString = [self setupCategoryString];
//    NSString *urlString = [NSString stringWithFormat: @"https://www.eventbriteapi.com/v3/events/search/?location.within=20km&location.latitude=%f&location.longitude=%f&categories=%@&start_date.range_end=%@&token=RDVVDO7YFDE4XNRYRMNM",self.userLocation.coordinate.latitude, self.userLocation.coordinate.longitude, categoryString, dateString];
//    
//    return urlString;
//}

-(void)getEventData {
    NSString *dateString = [self setupFirstDateString];
    NSString *categoryString = [self setupCategoryString];

    if (self.shouldRefreshFromFirstDay) {
        self.shouldRefreshFromFirstDay = NO;
        [EventbriteApi fetchEventDataWithCategoryString:categoryString dateString:dateString latitude:self.userLocation.coordinate.latitude longitude:self.userLocation.coordinate.longitude pageNumber:1 eventArray:nil success:^(NSArray *eventsArray) {
            self.events = eventsArray;
            [self updateMapForFirstDate];
            
            [EventbriteApi fetchEventDataWithCategoryString:categoryString dateString:dateString latitude:self.userLocation.coordinate.latitude longitude:self.userLocation.coordinate.longitude pageNumber:1 eventArray:nil success:^(NSArray *eventsArray) {
                self.events = eventsArray;
                //[self updateMap];
                
            } failure:^(NSString *failureMessage) {
                NSLog (@"FIRST EVENT API CALL FAILURE");
            }];
            
        } failure:^(NSString *failureMessage) {
             NSLog (@"SECOND EVENT API CALL FAILURE");
        }];
    }
    dateString = [self setupDateStringForNext:30];
    //NSString *urlString = [self setupUrlString];
    //EventbriteApi

    
//    [EventbriteApi fetchCategoryData:^(NSArray *categoryArray) {
//        self.categoryArray = categoryArray;
//        [self setCategoryPreferences:categoryArray];
//    } failure:^(NSString *error) {
//        NSLog(@"%@",error);
//    }];
    
    //https://www.eventbriteapi.com/v3/events/search/?location.longitude=-79.386517&token=RDVVDO7YFDE4XNRYRMNM&start_date.range_end=2016-08-30T00%3A00%3A00&location.latitude=43.656221&page=1&categories=103%2C101%2C110&location.within=20km
    //https://www.eventbriteapi.com/v3/events/search/?location.within=20km&location.latitude=43.656221&location.longitude=-79.386517&categories=103%2C101%2C110&start_date.range_end=2016-08-01T00%3A00%3A00&token=RDVVDO7YFDE4XNRYRMNM
}


- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    //    NSLog(@"Authorization changed");
    
    // If the user's allowed us to use their location, we can start getting location updates
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [self.locationManager startUpdatingLocation];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    
    CLLocation *userLocation = [locations lastObject];
    
    if (!self.initialLocationSet) {
        self.initialLocationSet = YES;
        
        CLLocationCoordinate2D userCoordinate = userLocation.coordinate;
        MKCoordinateRegion userRegion = MKCoordinateRegionMake(userCoordinate, MKCoordinateSpanMake(0.08, 0.08));
        [self.mapView setRegion:userRegion animated:YES];
        
        CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
        [geoCoder reverseGeocodeLocation:userLocation completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        }];
        self.userLocation.coordinate = userCoordinate;
        [self getEventData];
    }
}


#pragma mark - Annotations

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    
    
    if (annotation == mapView.userLocation) {
        self.userLocation.coordinate = mapView.userLocation.coordinate;
        return nil;
    }
    
    static NSString* UserAnnotationIdentifier = @"UserAnnotationIdentifier";
    
    if (annotation == self.userLocation) {
        [self.mapView removeOverlay:self.userRadius];
        MKPinAnnotationView *userAnnotationView = (MKPinAnnotationView*) [mapView dequeueReusableAnnotationViewWithIdentifier:UserAnnotationIdentifier];
        if (userAnnotationView == nil) {
            userAnnotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation
                                                                                      reuseIdentifier:UserAnnotationIdentifier];
        }
        userAnnotationView.pinTintColor = [UIColor redColor];//MKPinAnnotationColorRed;
        self.userRadius = [MKCircle circleWithCenterCoordinate:self.userLocation.coordinate radius:2000];
        [self.mapView addOverlay:self.userRadius];
        return userAnnotationView;
    }
    //    NSLog(@"Called pin annotation");
    MKPinAnnotationView *pav = (MKPinAnnotationView*) [mapView dequeueReusableAnnotationViewWithIdentifier:@"EventPin"];
    if (pav == nil) {
        pav = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"EventPin"];
    }
    
    UIButton *favouritesButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    [favouritesButton setImage:[UIImage imageNamed:@"plus"] forState: UIControlStateNormal];
    
    UIButton *URLButton =[UIButton buttonWithType:UIButtonTypeDetailDisclosure];
//    [URLButton setImage:[UIImage imageNamed:@"www"] forState: UIControlStateNormal];
    
    pav.leftCalloutAccessoryView = URLButton;
    pav.rightCalloutAccessoryView = favouritesButton;
    
    //Eventy *event = (Eventy *)annotation;
    
    pav.pinTintColor = [UIColor orangeColor];


    pav.canShowCallout=YES;
    

    return pav;
}
/*
-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    Eventy *clickedEvent = (Eventy *)view.annotation;
//    if (control == view.leftCalloutAccessoryView) {
//        //[[UIApplication sharedApplication] openURL:[NSURL URLWithString: clickedEvent.urlString]];
//        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//        NSArray *testArray = [NSKeyedUnarchiver unarchiveObjectWithData:[userDefaults objectForKey:@"FavouriteEventsArray"]];
//        for (SavedEvent *eventy in testArray) {
//            NSLog(@"test EVent: %@, %@, %@", event., event.address, event.url);
//        }
//    }
    if (control == view.rightCalloutAccessoryView) {
//        SavedEvent *savedEvent = [[SavedEvent alloc] init];
//        savedEvent.title = clickedEvent.title;
//        savedEvent.url = clickedEvent.urlString;
//        savedEvent.address = clickedEvent.address;
//        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        if ([[[userDefaults dictionaryRepresentation] allKeys] containsObject:@"FavouriteEventsArray"]) {
            NSArray *defaultsFaouritesEvents = [NSKeyedUnarchiver unarchiveObjectWithData:[userDefaults objectForKey:@"FavouriteEventsArray"]];
            NSMutableSet *favouriteEventsSet = [[NSMutableSet alloc] init];
            NSSet *defaultFavouritesSet = [favouriteEventsSet setByAddingObjectsFromArray:defaultsFaouritesEvents];
            favouriteEventsSet = [defaultFavouritesSet mutableCopy];
            if ([defaultFavouritesSet containsObject:savedEvent]) {
                [favouriteEventsSet removeObject:savedEvent];
                NSArray *newDefaultsFavouritesEvents = [favouriteEventsSet allObjects];
                NSData *data = [NSKeyedArchiver archivedDataWithRootObject:newDefaultsFavouritesEvents];
                [userDefaults setObject:data forKey:@"FavouriteEventsArray"];
            } else {
                [favouriteEventsSet addObject:savedEvent];
                NSArray *newDefaultsFavouritesEvents = [favouriteEventsSet allObjects];
                NSData *data = [NSKeyedArchiver archivedDataWithRootObject:newDefaultsFavouritesEvents];
                [userDefaults setObject:data forKey:@"FavouriteEventsArray"];
            }
        } else {
            NSArray *newEventFavourite = [[NSArray alloc] initWithObjects:savedEvent, nil];
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:newEventFavourite];
            [userDefaults setObject:data forKey:@"FavouriteEventsArray"];
        }
    }
}
*/
/////

#pragma mark - Wheel Delegate

- (void)wheelDidTurnClockwise:(BOOL)didTurnClockwise {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isLoadingDone"] == YES) {
        [self updateValueToIncrease:didTurnClockwise];
        [self updateDateLabel];
    }
}

- (void)updateValueToIncrease:(BOOL)toIncrease {
    if (toIncrease) {
        if (!(self.wheelValue > 28)) {
            self.wheelValue++;
            [self wheelAction];
        }
    } else {
        if (!(self.wheelValue < 1)) {
            self.wheelValue--;
            [self wheelAction];
        }
    }
}

-(void)wheelAction {
    NSInteger value = self.wheelValue;
    
    self.addedDays.day = value;
    
    NSCalendar *theCalendar = [NSCalendar currentCalendar];
    NSDate *date = [theCalendar dateByAddingComponents:self.addedDays toDate:[NSDate date] options:0];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    NSString *wheelDate = [dateFormatter stringFromDate:date];
    self.wheelLabelDate = date;
    [self getEventsForDates:wheelDate];
//    NSLog(@"wheel date: %@", wheelDate);
}

-(void)updateMap {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *Date = [dateFormatter stringFromDate:self.wheelLabelDate];
     [self getEventsForDates: Date];
}

-(void)updateMapForFirstDate {
    
    for (Eventy *event in self.events) {
        MKPointAnnotation *eventAnnotation = [MKPointAnnotation new];
        eventAnnotation.title = event.name;
        eventAnnotation.coordinate = CLLocationCoordinate2DMake([event.venue.latitude doubleValue], [event.venue.longitude doubleValue]) ;
        [self.mapView addAnnotation:eventAnnotation];
    }
    
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
//    NSDate *today = [NSDate date];
//    NSString *firstDate = [dateFormatter stringFromDate:today];
//    [self getEventsForDates:firstDate];
}

#pragma mark - Table View DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.selectedCategoryArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *currentCell = [tableView dequeueReusableCellWithIdentifier:@"legendCell" forIndexPath:indexPath];
    
    Category *category = self.selectedCategoryArray[indexPath.row];
    
    currentCell.backgroundColor = [UIColor clearColor];
    UIView *rectangleView = [currentCell viewWithTag:90];
    if (!rectangleView) {
        rectangleView  = [[UIView alloc] initWithFrame:CGRectMake(0, 0, currentCell.frame.size.width, currentCell.frame.size.height * 0.95)];
        rectangleView.tag = 90;
        rectangleView.center = CGPointMake(currentCell.frame.size.width/2, currentCell.frame.size.height/2);
        rectangleView.backgroundColor = [UIColor blackColor];
        rectangleView.alpha = 0.5;
        
        [currentCell addSubview:rectangleView];
    }
    
    UILabel *cellLabel = [currentCell viewWithTag:80];
    if (!cellLabel) {
        cellLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, currentCell.frame.size.width, currentCell.frame.size.height * 0.95)];
        cellLabel.backgroundColor = [UIColor clearColor];
        [cellLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:11]];
        cellLabel.tag = 80;
        cellLabel.textAlignment = NSTextAlignmentCenter;
        cellLabel.textColor = [UIColor whiteColor];
        
        [rectangleView addSubview:cellLabel];
    }
    
    
    UIView *colorSquare = [currentCell viewWithTag:100];
    if (!colorSquare) {
        colorSquare  = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        colorSquare.tag = 100;
        colorSquare.center = CGPointMake(currentCell.frame.size.width * 0.9, currentCell.frame.size.height/2);

        [currentCell addSubview:colorSquare];
    }
    cellLabel.text = category.title;
    switch (indexPath.row) {
        case 0:
            colorSquare.backgroundColor = [UIColor blueColor];
            break;
        case 1:
            colorSquare.backgroundColor = [UIColor greenColor];
            break;
        case 2:
            colorSquare.backgroundColor = [UIColor redColor];
            break;
        default:
            break;
    }
    return currentCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 21.0;
}

-(void)categoriesDidChange {
    self.shouldRefreshFromFirstDay = YES;
    self.originalCategorySelectionComplete = YES;
}

-(void)updateSelectedCategoryArray:(NSArray *)categoryArray {
    self.selectedCategoryArray = categoryArray;
    if (self.shouldRefreshFromFirstDay) {
        [self getEventData];
    }
}


-(void)getUserLocation {
    self.locationManager = [CLLocationManager new];
    self.locationManager.delegate = self;
    self.userLocation = [MKPointAnnotation new];
    UILongPressGestureRecognizer *changeLocationGesture =[[UILongPressGestureRecognizer alloc]
                                             initWithTarget:self action:@selector(handleChangeLocation:)];
    changeLocationGesture.minimumPressDuration = 0.2;
    [self.mapView addGestureRecognizer:changeLocationGesture];
    CLAuthorizationStatus authStatus = CLLocationManager.authorizationStatus;
    if (authStatus == kCLAuthorizationStatusNotDetermined) {
        [self.locationManager requestWhenInUseAuthorization];
    } else if (authStatus == kCLAuthorizationStatusAuthorizedWhenInUse){
        [self.locationManager startUpdatingLocation];
        [self prepareView];
        //[self populateCategories];
    }
}


- (void)handleChangeLocation:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan)
        return;
    CGPoint touchPoint = [gestureRecognizer locationInView:self.mapView];
    CLLocationCoordinate2D touchCoordinate = [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
    
    CLLocation *oldLocation = [[CLLocation alloc] initWithLatitude:self.userLocation.coordinate.latitude longitude:self.userLocation.coordinate.longitude] ;
    CLLocation *newLocation = [[CLLocation alloc] initWithLatitude:touchCoordinate.latitude longitude:touchCoordinate.longitude];
    self.userLocation.coordinate = touchCoordinate;
    NSLog(@"USER LOCATION IS: %f %f", touchCoordinate.latitude, touchCoordinate.longitude);
    [self.mapView addAnnotation:self.userLocation];
    [self.mapView removeOverlay:self.userRadius];
    self.userRadius = [MKCircle circleWithCenterCoordinate:self.userLocation.coordinate radius:2000];
    [self.mapView addOverlay:self.userRadius];
//    if (!self.originalCategorySelectionComplete) {
//        [self prepareView];
//        //[self populateCategories];
//        return;
//    }

    CLLocationDistance distanceForNewData = 17000;
    if ([oldLocation distanceFromLocation:newLocation] > distanceForNewData ) {
        [self getEventData];
    }
}

- (MKOverlayView *)mapView:(MKMapView *)map viewForOverlay:(id <MKOverlay>)overlay
{
    MKCircleView *circleView = [[MKCircleView alloc] initWithOverlay:overlay];
    circleView.strokeColor = [UIColor blueColor];
    circleView.fillColor = [[UIColor blueColor] colorWithAlphaComponent:0.3];
    return circleView;
}
@end
