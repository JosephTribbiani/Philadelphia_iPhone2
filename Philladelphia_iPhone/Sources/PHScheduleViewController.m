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

// cycling collection view number of items multipliers
#define kDaysCountMultiplier 3
#define kHoursCountMultiplies 2

@interface PHScheduleViewController () <UICollectionViewDataSource, PHSelectStationViewControllerDelegate, UIScrollViewDelegate, UICollectionViewDelegate, PHScheduleModelDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView* tripCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionView* hoursCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionView* weekdaysCollectionView;
@property (weak, nonatomic) IBOutlet UILabel *noTripsLabel;

@property (weak, nonatomic) IBOutlet UIButton* selectFromStationButton;
@property (weak, nonatomic) IBOutlet UIButton* selectToStationButton;

@property (strong, nonatomic) UIViewController* childViewController;
@property (strong, nonatomic) PHScheduleModel* model;

@property (strong, nonatomic) NSMutableArray* selectedWeekdayIndexes;
@property (strong, nonatomic) NSMutableArray* selectedHoursIndexes;

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
    self.hoursCollectionView.allowsMultipleSelection = YES;
    
    UICollectionViewFlowLayout *weekdaysViewlayout = (UICollectionViewFlowLayout*)self.weekdaysCollectionView.collectionViewLayout;
    weekdaysViewlayout.sectionInset = UIEdgeInsetsMake(0, 10, 0, 10);
    self.weekdaysCollectionView.allowsMultipleSelection = YES;
    
    [self selectCurrentDate];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (NSMutableArray*)selectedHoursIndexes
{
    if (_selectedHoursIndexes == nil)
    {
        _selectedHoursIndexes = [NSMutableArray new];
    }
    return _selectedHoursIndexes;
}


- (NSMutableArray*)selectedWeekdayIndexes
{
    if (_selectedWeekdayIndexes == nil)
    {
        _selectedWeekdayIndexes = [NSMutableArray new];
    }
    return _selectedWeekdayIndexes;
}

- (PHScheduleModel *)model
{
    if (_model == nil)
    {
        _model = [PHScheduleModel new];
        _model.delegate = self;
    }
    return _model;
}


#pragma mark - Selection

- (void)selectCurrentDate
{
    NSInteger dayToSelect = self.model.selectedDay;
    NSInteger hourToSelect = self.model.selectedTime;
    
    [self.weekdaysCollectionView reloadData];
    [self.hoursCollectionView reloadData];

    [self collectionView:self.weekdaysCollectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:dayToSelect inSection:0]];
    [self collectionView:self.hoursCollectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:hourToSelect inSection:0]];
    
    [self.weekdaysCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:dayToSelect inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
    [self.hoursCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:hourToSelect inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];

}

- (NSSet*)collectionView:(UICollectionView*)collectionView accompanyIndexesForIndexPath:(NSIndexPath*)indexPath
{
    NSMutableSet* mutableResult = [NSMutableSet new];
    if (collectionView == self.weekdaysCollectionView)
    {
        NSIndexPath* index1 = nil;
        NSIndexPath* index2 = nil;

        if (indexPath.item / [self.model.weekDays count] == 0)
        {
            index1 = [NSIndexPath indexPathForItem:indexPath.item + 3 inSection:0];
            index2 = [NSIndexPath indexPathForItem:indexPath.item + 6 inSection:0];
        }
        else if (indexPath.item / [self.model.weekDays count] == 1)
        {
            index1 = [NSIndexPath indexPathForItem:indexPath.item - 3 inSection:0];
            index2 = [NSIndexPath indexPathForItem:indexPath.item + 3 inSection:0];
        }
        else if (indexPath.item / [self.model.weekDays count] == 2)
        {
            index1 = [NSIndexPath indexPathForItem:indexPath.item - 3 inSection:0];
            index2 = [NSIndexPath indexPathForItem:indexPath.item - 6 inSection:0];
        }
        [mutableResult addObject:indexPath];
        [mutableResult addObject:index1];
        [mutableResult addObject:index2];
    }
    else if (collectionView == self.hoursCollectionView)
    {
        NSIndexPath* index = nil;
        if (indexPath.item / [self.model.hours count] == 0)
        {
            index = [NSIndexPath indexPathForItem:indexPath.item + [self.model.hours count] inSection:0];
        }
        else if (indexPath.item / [self.model.hours count] == 1)
        {
            index = [NSIndexPath indexPathForItem:indexPath.item - [self.model.hours count] inSection:0];
        }
        [mutableResult addObject:indexPath];
        [mutableResult addObject:index];
    }
    return [NSSet setWithSet:mutableResult];
}

- (void)collectionView:(UICollectionView*)collectionView selectItemAtIndexPath:(NSIndexPath*)indexPath
{
    NSMutableArray* selectedIndexes = nil;
    
    if (collectionView == self.weekdaysCollectionView)
    {
        selectedIndexes = self.selectedWeekdayIndexes;
        self.model.selectedDay = indexPath.item % [self.model.weekDays count];
    }
    else if (collectionView == self.hoursCollectionView)
    {
        selectedIndexes = self.selectedHoursIndexes;
        self.model.selectedTime = indexPath.item % [self.model.hours count];
    }
    
    [selectedIndexes enumerateObjectsUsingBlock:^(NSIndexPath* indexPath, NSUInteger idx, BOOL* stop)
    {
        [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    }];
    
    NSSet* indexPathesToSelect = [self collectionView:collectionView accompanyIndexesForIndexPath:indexPath];
    [indexPathesToSelect enumerateObjectsUsingBlock:^(NSIndexPath* indexPath, BOOL* stop)
     {
         [collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
         [selectedIndexes addObject:indexPath];
     }];
}

#pragma mark - CollectionViewDataSource

- (UICollectionViewCell*)collectionView:(UICollectionView*)collectionView cellForItemAtIndexPath:(NSIndexPath*)indexPath
{
    UICollectionViewCell* cell = nil;
    if (collectionView == self.tripCollectionView)
    {
        cell = [self.tripCollectionView dequeueReusableCellWithReuseIdentifier:@"tripsCollectionViewCell" forIndexPath:indexPath];
        NSDictionary* train = [self.model.trips objectAtIndex:indexPath.item];
        ((PHTripsCollectionViewCell*)cell).departureTime = train[@"startTime"];
        ((PHTripsCollectionViewCell*)cell).arrivalTime = train[@"endTime"];
        ((PHTripsCollectionViewCell*)cell).duration = train[@"duration"];
        ((PHTripsCollectionViewCell*)cell).isActual = [train[@"isActual"] boolValue];

    }
    else if (collectionView == self.hoursCollectionView)
    {
        cell = [self.hoursCollectionView dequeueReusableCellWithReuseIdentifier:@"hoursCollectionViewCell" forIndexPath:indexPath];
        ((PHHoursCollectionViewCell*)cell).title = [self.model.hours objectAtIndex:indexPath.item % [self.model.hours count]];
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
        result = [self.model.weekDays count] * kDaysCountMultiplier;
    }
    else if (collectionView == self.hoursCollectionView)
    {
        result = [self.model.hours count] * kHoursCountMultiplies;
    }
    else
    {
        result = [self.model.trips count];
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

- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

#pragma mark - CollectionViewDelegate

- (void)collectionView:(UICollectionView*)collectionView didSelectItemAtIndexPath:(NSIndexPath*)indexPath
{
    if (collectionView != self.tripCollectionView)
    {
        [self collectionView:collectionView selectItemAtIndexPath:indexPath];
    }
}

#pragma mark - ScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat topBound = 0;
    CGFloat bottomBound = 0;
    CGFloat period = 0;
    
    if (scrollView == self.weekdaysCollectionView)
    {
        bottomBound = scrollView.contentSize.width / kDaysCountMultiplier / 2;
        topBound = scrollView.contentSize.width / kDaysCountMultiplier * 2;
        period = scrollView.contentSize.width / kDaysCountMultiplier;
    }
    else if (scrollView == self.hoursCollectionView)
    {
        topBound = scrollView.contentSize.width - scrollView.contentSize.width / kHoursCountMultiplies / 2;
        bottomBound = scrollView.contentSize.width / kHoursCountMultiplies / 2;
        period = scrollView.contentSize.width / kHoursCountMultiplies;
    }
    
    if (scrollView != self.tripCollectionView)
    {
        if (scrollView.contentOffset.x < bottomBound)
        {
            scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x + period, scrollView.contentOffset.y);
        }
        if (scrollView.contentOffset.x > topBound)
        {
            scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x - period, scrollView.contentOffset.y);
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
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)switchFromToStations:(id)sender
{
    PHStation* fromStation = self.model.fromStation;
    self.model.fromStation = self.model.toStation;
    self.model.toStation = fromStation;
    
    [self.selectToStationButton setAttributedTitle:[self attributedButtonTitleForTitle:self.model.toStation.name] forState:UIControlStateNormal];
    [self.selectFromStationButton setAttributedTitle:[self attributedButtonTitleForTitle:self.model.fromStation.name] forState:UIControlStateNormal];
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
    if (station != self.model.fromStation)
    {
        [self.selectToStationButton setAttributedTitle:[self attributedButtonTitleForTitle:station.name] forState:UIControlStateNormal];
        self.model.toStation = station;
        [self hideViewController:self.childViewController];
    }
}

- (void)tableView:(PHSelectStationViewController *)tableView fromStationDidSelect:(PHStation *)station
{
    if (station != self.model.toStation)
    {
        self.model.fromStation = station;
        [self.selectFromStationButton setAttributedTitle:[self attributedButtonTitleForTitle:station.name] forState:UIControlStateNormal];
        [self hideViewController:self.childViewController];
    }
}

#pragma mark -

- (NSAttributedString*)attributedButtonTitleForTitle:(NSString*)title
{
    NSAttributedString* attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:@{NSFontAttributeName: [UIFont fontWithName:@"DINCondensed-Bold" size:17],
                                                                                                        NSForegroundColorAttributeName : [UIColor whiteColor]}];
    return attributedTitle;
}

#pragma mark - ScheduleModelDelegate

- (void)shouldUpdateTrips
{
    [self.tripCollectionView reloadData];
    if ([self.model.trips count] == 0)
    {
        [self.noTripsLabel setHidden:NO];
        NSString* text = NSLocalizedString(@"noTrips", @"");
        NSAttributedString* attributedTitle = [[NSAttributedString alloc] initWithString:text attributes:@{NSFontAttributeName: [UIFont fontWithName:@"DINCondensed-Bold" size:20],
                                                                                                                           NSForegroundColorAttributeName : [UIColor whiteColor]}];
        [self.noTripsLabel setAttributedText:attributedTitle];
    }
    else
    {
        [self.noTripsLabel setHidden:YES];
        NSInteger index = 0;
        for (NSDictionary* trip in self.model.trips)
        {
            if ([trip[@"isActual"] boolValue] != NO)
            {
                [self.tripCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
                break;
            }
            index++;
        }
    }
}

@end
