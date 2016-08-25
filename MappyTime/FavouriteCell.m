//
//  FavouriteCell.m
//  MappyTime
//
//  Created by Anthony Tulai on 2016-02-11.
//  Copyright © 2016 Anthony Tulai. All rights reserved.
//

#import "FavouriteCell.h"

@implementation FavouriteCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, self.frame.size.width*0.5, self.frame.size.height)];
        [self addSubview:self.titleLabel];
        _dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(20 + self.frame.size.width*0.5, 0, self.frame.size.width*0.5, self.frame.size.height)];
        [self addSubview:self.dateLabel];
        _isGoingImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width*0.95 + 20, 10, self.frame.size.width*0.10, self.frame.size.height - 20)];
        _isGoingImageView.image = [UIImage imageNamed:@"checkbox-unchecked"];
        [self addSubview:_isGoingImageView];
        _isGoing = NO;
    }
    return self;
}

@end

