//
//  CategorySelectorTableViewController.m
//  MappyTime
//
//  Created by Anthony Tulai on 2016-07-21.
//  Copyright © 2016 Anthony Tulai. All rights reserved.
//

#import "CategorySelectorTableViewController.h"
#import "Category.h"


@interface CategorySelectorTableViewController ()
@property (strong, nonatomic) NSMutableArray *selectedCategories;

@end

@implementation CategorySelectorTableViewController

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.delegate updateSelectedCategoryArray:[self.selectedCategories copy]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initializeGlobalVariables];
    [self setupTableHeader];
    [self.tableView reloadData];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.categoryArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"categoryCell" forIndexPath:indexPath];
    
    Category *category = self.categoryArray[indexPath.row];
    cell.textLabel.text = category.title;
    
    if ([self isPrefrence:category]) {
        [cell.imageView setImage:[UIImage imageNamed:@"checked"]];
        category.isFavourite = YES;
    } else {
        [cell.imageView setImage:[UIImage imageNamed:@"unchecked"]];
        category.isFavourite = NO;
    }
    // Configure the cell...
    //cell.imageView.image =
    return cell;
}

#pragma mark - UI Changes

-(void) setupTableHeader {
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 60)];
    titleLabel.text = @"SELECT YOUR FAVOURITE EVENT CATEGORIES";
    
    [self.tableView setTableHeaderView:titleLabel];
    
}

#pragma mark - action methods

-(void)initializeGlobalVariables {
    self.selectedCategories = [NSMutableArray new];
    
}

-(bool) isPrefrence:(Category *)category {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults objectForKey:@"categorypreference0"]) {
        if ([category.categoryId isEqualToString:[userDefaults objectForKey:@"categorypreference0"]] ||
            [category.categoryId isEqualToString:[userDefaults objectForKey:@"categorypreference1"]] ||
            [category.categoryId isEqualToString:[userDefaults objectForKey:@"categorypreference2"]]
           ) {
            return YES;
        }
    }
    return NO;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Category *selectedCategory = self.categoryArray[indexPath.row];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (!selectedCategory.isFavourite && self.selectedCategories.count >= 3) {
        [self presentAlert];
    } else if (!selectedCategory.isFavourite) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        if (self.selectedCategories.count) {
            [userDefaults setObject:selectedCategory.categoryId forKey:[@"categorypreference" stringByAppendingString:[@(self.selectedCategories.count) stringValue]]];
        } else {
            [userDefaults setObject:selectedCategory.categoryId forKey:@"categorypreference0"];
        }
        [userDefaults synchronize];
        selectedCategory.isFavourite = YES;
        [self.selectedCategories addObject:selectedCategory];
        [cell.imageView setImage:[UIImage imageNamed:@"checked"]];
        [self.delegate categoriesDidChange];
       

    } else {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults removeObjectForKey:[@"categorypreference" stringByAppendingString:[@(self.selectedCategories.count - 1) stringValue]]];
        [userDefaults synchronize];
        selectedCategory.isFavourite = NO;
        [self.selectedCategories removeObject:selectedCategory];
        [cell.imageView setImage:[UIImage imageNamed:@"unchecked"]];
        [self.delegate categoriesDidChange];
        
    }
}

-(void) presentAlert {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Maximum Prefered Categories Reached" message:@"Because of the sheer volume of events we limit the number of categories you can select to three." preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"OKAY PRESSED");
    }];
    
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:^{
    }];

}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
