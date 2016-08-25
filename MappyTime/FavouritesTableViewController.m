//
//  FavouritesViewController.m
//  FavouritesTable
//
//  Created by Anthony Tulai on 2016-02-10.
//  Copyright © 2016 Anthony Tulai. All rights reserved.
//

#import "FavouritesTableViewController.h"
#import "FavouriteCell.h"
//#import "Event.h"

@interface FavouritesTableViewController ()

@property (strong, nonatomic) NSMutableArray *favouriteEvents;
@property (strong, nonatomic) UIView *headerView;

@end

@implementation FavouritesTableViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 100)];
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 40, 100)];
    headerLabel.numberOfLines = 0;
    [self.headerView addSubview:headerLabel];
    headerLabel.text = @"Click on your event to mark yourself as going";
    
    self.tableView.tableHeaderView = self.headerView;
    self.favouriteEvents  = [[NSMutableArray alloc] init];
    [self.tableView reloadData];
    [self.tableView registerClass:[FavouriteCell class] forCellReuseIdentifier:@"favouritesCell"];
    
    [self prepareDoneButton];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FavouriteCell *currentCell = [tableView dequeueReusableCellWithIdentifier:@"favouritesCell"];
    //Event *currentEvent = [self.favouriteEvents objectAtIndex:indexPath.row];
    //currentCell.titleLabel.text = currentEvent.title;
    //currentCell.dateLabel.text = currentEvent.selectedDate;
    
    return currentCell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.favouriteEvents count];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    FavouriteCell *selectedCell = (FavouriteCell *)[tableView cellForRowAtIndexPath:indexPath];
    if (selectedCell.isGoing) {
        selectedCell.isGoing = NO;
        selectedCell.isGoingImageView.image = [UIImage imageNamed:@"checkbox-unchecked"];
    } else {
        selectedCell.isGoing = YES;
        selectedCell.isGoingImageView.image = [UIImage imageNamed:@"checkbox-yes"];
        
    }
    [self.tableView reloadData];
}

-(void)prepareDoneButton {
    UIButton *doneButton  = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 70, 30)];
    doneButton.center = CGPointMake(self.headerView.frame.size.width * 0.9, self.headerView.frame.size.height * 0.5);
    doneButton.backgroundColor = [UIColor redColor];
    doneButton.titleLabel.textColor = [UIColor whiteColor];
    doneButton.titleLabel.text = @"Done";
    [doneButton addTarget:self action:@selector(doneButton) forControlEvents:UIControlEventTouchUpInside];
    [self.headerView addSubview:doneButton];
}

- (IBAction)doneButton {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
