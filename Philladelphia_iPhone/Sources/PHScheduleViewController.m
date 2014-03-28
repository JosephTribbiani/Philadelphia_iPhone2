//
//  PHScheduleViewController.m
//  Philladelphia_iPhone
//
//  Created by Igor Bogatchuk on 3/26/14.
//  Copyright (c) 2014 Igor Bogatchuk. All rights reserved.
//

#import "PHScheduleViewController.h"
#import "PHAppDelegate.h"
#import "PHLine.h"
#import "PHStation.h"
#import "PHTripsCollectionViewCell.h"
#import "PHHoursCollectionViewCell.h"
#import "PHWeekDaysCollectionViewCell.h"
#import "PHSelectStationViewController.h"

#import "PHScheduleModel.h"

#define kAnimationDuration 0.2

@interface PHScheduleViewController () <UICollectionViewDataSource, PHSelectStationViewControllerDelegate, UIScrollViewDelegate, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView* tripCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionView* hoursCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionView* weekdaysCollectionView;

@property (weak, nonatomic) IBOutlet UIButton* selectFromStationButton;
@property (weak, nonatomic) IBOutlet UIButton* selectToStationButton;

@property (strong, nonatomic) UIViewController* childViewController;
@property (strong, nonatomic) PHScheduleModel* model;
@property (strong, nonatomic) NSMutableArray* selectedWeekdayIndexes;

@end

@implementation PHScheduleViewController

- (id)initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self prepareUI];
    self.selectedWeekdayIndexes = [NSMutableArray new];
}

- (void)prepareUI
{
    NSString* selectStationTitle = NSLocalizedString(@"stationPlaceholder", @"");
    [self.selectFromStationButton setAttributedTitle:[self attributedButtonTitleForTitle:selectStationTitle] forState:UIControlStateNormal];
    [self.selectToStationButton setAttributedTitle:[self attributedButtonTitleForTitle:selectStationTitle] forState:UIControlStateNormal];
    self.selectToStationButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    self.selectFromStationButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    self.selectFromStationButton.contentEdgeInsets = UIEdgeInsetsMake(0, 15, 0, 0);
    self.selectToStationButton.contentEdgeInsets = UIEdgeInsetsMake(0, 15, 0, 0);
    
    UICollectionViewFlowLayout *tripsViewlayout = (UICollectionViewFlowLayout*)self.tripCollectionView.collectionViewLayout;
    tripsViewlayout.sectionInset = UIEdgeInsetsMake(0, 10, 0, 10);
    
    UICollectionViewFlowLayout *hoursViewlayout = (UICollectionViewFlowLayout*)self.hoursCollectionView.collectionViewLayout;
    hoursViewlayout.sectionInset = UIEdgeInsetsMake(0, 10, 0, 10);
    
    UICollectionViewFlowLayout *weekdaysViewlayout = (UICollectionViewFlowLayout*)self.weekdaysCollectionView.collectionViewLayout;
    weekdaysViewlayout.sectionInset = UIEdgeInsetsMake(0, 10, 0, 10);
    self.weekdaysCollectionView.allowsMultipleSelection = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (PHScheduleModel *)model
{
    if (_model == nil)
    {
        _model = [PHScheduleModel new];
    }
    return _model;
}

#pragma mark - CollectionViewDataSource

- (UICollectionViewCell*)collectionView:(UICollectionView*)collectionView cellForItemAtIndexPath:(NSIndexPath*)indexPath
{
    UICollectionViewCell* cell = nil;
    if (collectionView == self.tripCollectionView)
    {
        cell = [self.tripCollectionView dequeueReusableCellWithReuseIdentifier:@"tripsCollectionViewCell" forIndexPath:indexPath];
        NSDictionary* train = [self.model.trips objectAtIndex:indexPath.item];
        ((PHTripsCollectionViewCell*)cell).startTimeLabel.text = train[@"startTime"];
        ((PHTripsCollectionViewCell*)cell).endTimeLabel.text = train[@"endTime"];
        ((PHTripsCollectionViewCell*)cell).durationLabel.text = train[@"trainId"];
    }
    else if (collectionView == self.hoursCollectionView)
    {
        cell = [self.hoursCollectionView dequeueReusableCellWithReuseIdentifier:@"hoursCollectionViewCell" forIndexPath:indexPath];
        ((PHHoursCollectionViewCell*)cell).title = [self.model.hours objectAtIndex:indexPath.item];
    }
    else
    {
        cell = [self.weekdaysCollectionView dequeueReusableCellWithReuseIdentifier:@"weekdaysCollectionViewCell" forIndexPath:indexPath];
        ((PHWeekDaysCollectionViewCell*)cell).title = [self.model.weekDays objectAtIndex:indexPath.item % 3];
    }
    return cell;
}

- (NSInteger)collectionView:(UICollectionView*)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger result = 0;
    if (collectionView == self.weekdaysCollectionView)
    {
        result = [self.model.weekDays count] * 3;
    }
    else if (collectionView == self.hoursCollectionView)
    {
        result = [self.model.hours count];
    }
    else
    {
        result = 10;
    }
    return result;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (BOOL)collectionView:(UICollectionView*)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath*)indexPath
{
    return YES;
}

- (BOOL)collectionView:(UICollectionView*)collectionView shouldSelectItemAtIndexPath:(NSIndexPath*)indexPath;
{
    return YES;
}

#pragma mark - CollectionViewDelegate

- (void)collectionView:(UICollectionView*)collectionView didSelectItemAtIndexPath:(NSIndexPath*)indexPath
{
    if (collectionView == self.weekdaysCollectionView)
    {
        if ([self.selectedWeekdayIndexes count] > 0)
        {
            for (NSIndexPath* indexPath in self.selectedWeekdayIndexes)
            {
                [self.weekdaysCollectionView deselectItemAtIndexPath:indexPath animated:NO];
            }
        }
        NSIndexPath* index1 = nil;
        NSIndexPath* index2 = nil;
        if (indexPath.item / 3 == 0)
        {
            index1 = [NSIndexPath indexPathForItem:indexPath.item + 3 inSection:0];
            index2 = [NSIndexPath indexPathForItem:indexPath.item + 6 inSection:0];
        }
        else if (indexPath.item / 3 == 1)
        {
            index1 = [NSIndexPath indexPathForItem:indexPath.item - 3 inSection:0];
            index2 = [NSIndexPath indexPathForItem:indexPath.item + 3 inSection:0];
        }
        else if (indexPath.item / 3 == 2)
        {
            index1 = [NSIndexPath indexPathForItem:indexPath.item - 3 inSection:0];
            index2 = [NSIndexPath indexPathForItem:indexPath.item - 6 inSection:0];
        }
        [self.weekdaysCollectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
        [self.weekdaysCollectionView selectItemAtIndexPath:index1 animated:NO scrollPosition:UICollectionViewScrollPositionNone];
        [self.weekdaysCollectionView selectItemAtIndexPath:index2 animated:NO scrollPosition:UICollectionViewScrollPositionNone];
        [self.selectedWeekdayIndexes addObject:indexPath];
        [self.selectedWeekdayIndexes addObject:index1];
        [self.selectedWeekdayIndexes addObject:index2];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == self.weekdaysCollectionView)
    {
        NSIndexPath* index1 = nil;
        NSIndexPath* index2 = nil;
        if (indexPath.item / 3 == 0)
        {
            index1 = [NSIndexPath indexPathForItem:indexPath.item + 3 inSection:0];
            index2 = [NSIndexPath indexPathForItem:indexPath.item + 6 inSection:0];
        }
        else if (indexPath.item / 3 == 1)
        {
            index1 = [NSIndexPath indexPathForItem:indexPath.item - 3 inSection:0];
            index2 = [NSIndexPath indexPathForItem:indexPath.item + 3 inSection:0];
        }
        else if (indexPath.item / 3 == 2)
        {
            index1 = [NSIndexPath indexPathForItem:indexPath.item - 3 inSection:0];
            index2 = [NSIndexPath indexPathForItem:indexPath.item - 6 inSection:0];
        }
        [self.weekdaysCollectionView deselectItemAtIndexPath:indexPath animated:NO];
        [self.weekdaysCollectionView deselectItemAtIndexPath:index1 animated:NO];
        [self.weekdaysCollectionView deselectItemAtIndexPath:index2 animated:NO];
        [self.selectedWeekdayIndexes removeAllObjects];
    }
}

#pragma mark - ScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == self.weekdaysCollectionView)
    {
        if (scrollView.contentOffset.x < scrollView.contentSize.width / 6)
        {
            scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x + scrollView.contentSize.width / 3, scrollView.contentOffset.y);
        }
        if (scrollView.contentOffset.x > scrollView.contentSize.width / 3 * 2)
        {
            scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x - scrollView.contentSize.width / 3, scrollView.contentOffset.y);
        }
    }
}

#pragma mark - Actions

- (IBAction)selectFromStationDidTapped:(id)sender
{
    if (self.childViewController)
    {
        [self hideViewController:self.childViewController];
    }
    else
    {
        PHSelectStationViewController* childViewController = [[PHSelectStationViewController alloc] initWithNibName:@"PHSelectStationViewController" bundle:nil];
        childViewController.line = self.line;
        childViewController.stationType = PHStationTypeFrom;
        childViewController.delegate = self;
        [self displayViewController:childViewController relativeToView:self.selectFromStationButton];
    }
}
- (IBAction)backButtonDidTapped:(id)sender
{
    
}

- (IBAction)switchFromToStations:(id)sender
{

}

- (IBAction)selectToStationDidTapped:(id)sender
{
    if (self.childViewController)
    {
        [self hideViewController:self.childViewController];
    }
    else
    {
        PHSelectStationViewController* childViewController = [[PHSelectStationViewController alloc] initWithNibName:@"PHSelectStationViewController" bundle:nil];
        childViewController.line = self.line;
        childViewController.delegate = self;
        childViewController.stationType = PHStationTypeTo;
        [self displayViewController:childViewController relativeToView:self.selectToStationButton];
    }
}

#pragma mark - ChilViewController related

- (void)displayViewController:(UIViewController*)viewController relativeToView:(UIView*)view
{
    [viewController willMoveToParentViewController:self];
	[self addChildViewController:viewController];
	
    CGRect fromButtonFrame = view.frame;
    CGPoint origin = CGPointMake(fromButtonFrame.origin.x, fromButtonFrame.origin.y + fromButtonFrame.size.height);
    CGRect endFrame = CGRectMake(origin.x, origin.y, fromButtonFrame.size.width, 320);
    
    CGRect startFrame = endFrame;
    startFrame.size.height = 0;
    
    viewController.view.frame = startFrame;
    
	[UIView animateWithDuration:0.3 animations:^
    {
        viewController.view.frame = endFrame;
        [self.view addSubview:viewController.view];
    }];
	self.childViewController = viewController;
	[viewController didMoveToParentViewController:self];
}

- (void)hideViewController:(UIViewController*)viewController
{
    [viewController willMoveToParentViewController:nil];
	CGRect endFrame = viewController.view.frame;
	endFrame.size.height = 0;
    
	[UIView animateWithDuration:kAnimationDuration animations:^
    {
        viewController.view.frame = endFrame;
    }
    completion:^(BOOL finished)
    {
        [viewController.view removeFromSuperview];
        [viewController removeFromParentViewController];
        self.childViewController = nil;
        [viewController didMoveToParentViewController:nil];
    }];
}

#pragma mark - PHSelectStationViewControllerDelegate

- (void)tableView:(PHSelectStationViewController *)tableView toStationDidSelect:(PHStation *)station
{
    [self.selectToStationButton setAttributedTitle:[self attributedButtonTitleForTitle:station.name] forState:UIControlStateNormal];
    self.model.toStation = station;
    [self hideViewController:self.childViewController];
}

- (void)tableView:(PHSelectStationViewController *)tableView fromStationDidSelect:(PHStation *)station
{
    self.model.fromStation = station;
    [self.selectFromStationButton setAttributedTitle:[self attributedButtonTitleForTitle:station.name] forState:UIControlStateNormal];
    [self hideViewController:self.childViewController];
}

#pragma mark -

- (NSAttributedString*)attributedButtonTitleForTitle:(NSString*)title
{
    NSAttributedString* attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:@{NSFontAttributeName: [UIFont fontWithName:@"DINCondensed-Bold" size:17],
                                                                                                        NSForegroundColorAttributeName : [UIColor whiteColor]}];
    return attributedTitle;
}

@end
