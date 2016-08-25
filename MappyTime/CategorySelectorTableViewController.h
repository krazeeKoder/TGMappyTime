//
//  CategorySelectorTableViewController.h
//  MappyTime
//
//  Created by Anthony Tulai on 2016-07-21.
//  Copyright © 2016 Anthony Tulai. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "Category.h"

@protocol CategorySelectorDelegate <NSObject>

-(void)updateSelectedCategoryArray:(NSArray *)categoryArray;
-(void)categoriesDidChange;

@end

@interface CategorySelectorTableViewController : UITableViewController

@property (strong, nonatomic) NSArray *categoryArray;
@property (weak, nonatomic) id <CategorySelectorDelegate> delegate;

@end
