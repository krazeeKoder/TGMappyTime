//
//  FavouriteCell.h
//  MappyTime
//
//  Created by Anthony Tulai on 2016-02-11.
//  Copyright © 2016 Anthony Tulai. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FavouriteCell : UITableViewCell

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *dateLabel;
@property (strong, nonatomic) UIImageView *isGoingImageView;
@property (assign, nonatomic) bool isGoing;

@end
