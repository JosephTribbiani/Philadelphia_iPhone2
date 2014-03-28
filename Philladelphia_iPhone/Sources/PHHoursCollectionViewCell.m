//
//  PHHoursCollectionView.m
//  Philladelphia_iPhone
//
//  Created by Igor Bogatchuk on 3/26/14.
//  Copyright (c) 2014 Igor Bogatchuk. All rights reserved.
//

#import "PHHoursCollectionViewCell.h"
#import <QuartzCore/QuartzCore.h>

#define kFontSize 20

@interface PHHoursCollectionViewCell()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation PHHoursCollectionViewCell

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        UIView* backgroundView = [[UIView alloc] initWithFrame:self.bounds];
        backgroundView.backgroundColor = [UIColor clearColor];
        self.contentView.layer.borderColor = [UIColor whiteColor].CGColor;
        self.contentView.layer.borderWidth = 1.0f;
        self.backgroundView = backgroundView;
        
        UIView* selectedBackgroundView = [[UIView alloc] initWithFrame:self.bounds];
        selectedBackgroundView.backgroundColor = [UIColor whiteColor];
        self.selectedBackgroundView = selectedBackgroundView;
        
        [self addObserver:self forKeyPath:@"selected" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

- (void)setTitle:(NSString *)title
{
    _title = title;
    UIColor* color = self.isSelected ? [UIColor colorWithRed:74.0/255 green:120.0/255 blue:190.0/255 alpha:1] : [UIColor whiteColor];
    NSAttributedString* attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:@{NSFontAttributeName: [UIFont fontWithName:@"DINCondensed-Bold" size:kFontSize],
                                                                                                        NSForegroundColorAttributeName : color}];
    [self.titleLabel setAttributedText:attributedTitle];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"selected"])
    {
        UIColor* color = self.isSelected ? [UIColor colorWithRed:74.0/255 green:120.0/255 blue:190.0/255 alpha:1] : [UIColor whiteColor];
        NSAttributedString* attributedTitle = [[NSAttributedString alloc] initWithString:self.titleLabel.text attributes:@{NSFontAttributeName: [UIFont fontWithName:@"DINCondensed-Bold" size:kFontSize],
                                                                                                                           NSForegroundColorAttributeName : color}];
        [self.titleLabel setAttributedText:attributedTitle];
    }
}
@end
