//
//  PHSelectStationViewController.m
//  Philladelphia_iPhone
//
//  Created by Igor Bogatchuk on 3/27/14.
//  Copyright (c) 2014 Igor Bogatchuk. All rights reserved.
//

#import "PHSelectStationViewController.h"
#import "PHStation+Utils.h"

@interface PHSelectStationViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray* stations;

@end

@implementation PHSelectStationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)setLine:(PHLine *)line
{
    _line = line;
    self.stations = [[self.line.stations allObjects] sortedArrayUsingComparator:^NSComparisonResult(PHStation* station1, PHStation* station2)
                     {
                         return [@([station1 positionForLine:self.line direction:0]) compare:@([station2 positionForLine:self.line direction:0])];
                     }];
}

#pragma mark - TableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.stationType == PHStationTypeFrom)
    {
        [self.delegate tableView:self fromStationDidSelect:[self.stations objectAtIndex:indexPath.row]];
    }
    else
    {
        [self.delegate tableView:self toStationDidSelect:[self.stations objectAtIndex:indexPath.row]];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - TableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.stations count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.textLabel.attributedText = [self attributedCellTitleForTitle:[[self.stations objectAtIndex:indexPath.row] name]];
    cell.backgroundColor = [UIColor colorWithRed:74.0/255 green:120.0/255 blue:190.0/255 alpha:1];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

#pragma mark - 

- (NSAttributedString*)attributedCellTitleForTitle:(NSString*)title
{
    NSAttributedString* attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:@{NSFontAttributeName: [UIFont fontWithName:@"DINCondensed-Bold" size:17],
                                                                                                        NSForegroundColorAttributeName : [UIColor whiteColor]}];
    return attributedTitle;
}

@end
