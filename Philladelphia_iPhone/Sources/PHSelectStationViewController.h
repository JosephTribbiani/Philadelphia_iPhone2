//
//  PHSelectStationViewController.h
//  Philladelphia_iPhone
//
//  Created by Igor Bogatchuk on 3/27/14.
//  Copyright (c) 2014 Igor Bogatchuk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PHLine.h"

typedef enum
{
    PHStationTypeFrom,
    PHStationTypeTo
} PHStationType;

@class PHSelectStationViewController;

@protocol PHSelectStationViewControllerDelegate <NSObject>

- (void)tableView:(PHSelectStationViewController*)tableView fromStationDidSelect:(PHStation*)station;
- (void)tableView:(PHSelectStationViewController*)tableView toStationDidSelect:(PHStation*)station;

@end

@interface PHSelectStationViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIView *view;
@property (strong, nonatomic) PHLine* line;
@property (nonatomic, assign) PHStationType stationType;
@property (nonatomic, weak) id<PHSelectStationViewControllerDelegate> delegate;

@end
