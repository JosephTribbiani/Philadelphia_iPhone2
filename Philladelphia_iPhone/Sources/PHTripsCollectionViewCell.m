//
//  PHTripsCollectionViewCell.m
//  Philladelphia_iPhone
//
//  Created by Igor Bogatchuk on 3/26/14.
//  Copyright (c) 2014 Igor Bogatchuk. All rights reserved.
//

#import "PHTripsCollectionViewCell.h"

#define kFontSize 20

@interface PHTripsCollectionViewCell()

@property (weak, nonatomic) IBOutlet UILabel *startTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *endTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;

@end

@implementation PHTripsCollectionViewCell


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

- (void)setDepartureTime:(NSString *)departureTime
{
    _departureTime = departureTime;
    UIColor* color = self.isSelected ? [UIColor colorWithRed:74.0/255 green:120.0/255 blue:190.0/255 alpha:1] : [UIColor whiteColor];
    NSAttributedString* attributedTitle = [[NSAttributedString alloc] initWithString:departureTime attributes:@{NSFontAttributeName: [UIFont fontWithName:@"DINCondensed-Bold" size:kFontSize],
                                                                                                                NSForegroundColorAttributeName : color}];
    [self.startTimeLabel setAttributedText:attributedTitle];
}

- (void)setDuration:(NSString *)duration
{
    _duration = duration;
    UIColor* color = self.isSelected ? [UIColor colorWithRed:74.0/255 green:120.0/255 blue:190.0/255 alpha:1] : [UIColor whiteColor];
    NSAttributedString* attributedTitle = [[NSAttributedString alloc] initWithString:duration attributes:@{NSFontAttributeName: [UIFont fontWithName:@"DINCondensed-Bold" size:kFontSize],
                                                                                                           NSForegroundColorAttributeName : color}];
    [self.durationLabel setAttributedText:attributedTitle];
}

- (void)setArrivalTime:(NSString *)arrivalTime
{
    _arrivalTime = arrivalTime;
    UIColor* color = self.isSelected ? [UIColor colorWithRed:74.0/255 green:120.0/255 blue:190.0/255 alpha:1] : [UIColor whiteColor];
    NSAttributedString* attributedTitle = [[NSAttributedString alloc] initWithString:arrivalTime attributes:@{NSFontAttributeName: [UIFont fontWithName:@"DINCondensed-Bold" size:kFontSize],
                                                                                                              NSForegroundColorAttributeName : color}];
    [self.endTimeLabel setAttributedText:attributedTitle];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"selected"])
    {
        UIColor* color = self.isSelected ? [UIColor colorWithRed:74.0/255 green:120.0/255 blue:190.0/255 alpha:1] : [UIColor whiteColor];
        
        NSAttributedString* departureTime = [[NSAttributedString alloc] initWithString:self.startTimeLabel.text attributes:@{NSFontAttributeName: [UIFont fontWithName:@"DINCondensed-Bold" size:kFontSize],
                                                                                                                         NSForegroundColorAttributeName : color}];
        NSAttributedString* arrivalTime = [[NSAttributedString alloc] initWithString:self.endTimeLabel.text attributes:@{NSFontAttributeName: [UIFont fontWithName:@"DINCondensed-Bold" size:kFontSize],
                                                                                                                         NSForegroundColorAttributeName : color}];
        NSAttributedString* duration = [[NSAttributedString alloc] initWithString:self.durationLabel.text attributes:@{NSFontAttributeName: [UIFont fontWithName:@"DINCondensed-Bold" size:kFontSize],
                                                                                                                         NSForegroundColorAttributeName : color}];
        [self.durationLabel setAttributedText:duration];
        [self.startTimeLabel setAttributedText:departureTime];
        [self.endTimeLabel setAttributedText:arrivalTime];
    }
}


@end
