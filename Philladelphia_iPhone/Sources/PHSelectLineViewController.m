//
//  PHSelectLineViewController.m
//  Philladelphia_iPhone
//
//  Created by Igor Bogatchuk on 3/26/14.
//  Copyright (c) 2014 Igor Bogatchuk. All rights reserved.
//

#import "PHSelectLineViewController.h"
#import "PHAppDelegate.h"
#import "PHCoreDataManager.h"
#import "PHScheduleViewController.h"

#import "PHLine.h"

@interface PHSelectLineViewController () <PHCoreDatamanagerDelegate, UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) PHCoreDataManager* coreDataManager;
@property (nonatomic, strong) NSArray* lines;
@property (nonatomic, strong) PHLine* selectedLine;

@end

@implementation PHSelectLineViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (PHCoreDataManager*)coreDataManager
{
    if (_coreDataManager == nil)
    {
        _coreDataManager = ((PHAppDelegate*)[UIApplication sharedApplication].delegate).coreDataManger;
        _coreDataManager.delegate = self;
    }
    return _coreDataManager;
}

- (NSArray *)lines
{
    if (_lines == nil)
    {
        NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"PHLine"];
        _lines = [self.coreDataManager.managedObjectContext executeFetchRequest:request error:NULL];
    }
    return _lines;
}

#pragma mark - CoreDataManagerDelegate

- (void)trainMapDidLoad
{
    [self.tableView reloadData];
}

#pragma mark - TableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.lines count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"Cell"];
    [cell.textLabel setText:[[self.lines objectAtIndex:indexPath.row] name]];
    return cell;
}

#pragma mark - TableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedLine = self.lines[indexPath.row];
    [self performSegueWithIdentifier:@"showScheduleSegue" sender:self];
}

#pragma mark -

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showScheduleSegue"])
    {
        PHScheduleViewController* scheduleViewController = segue.destinationViewController;
        scheduleViewController.line = self.selectedLine;
    }
}

@end
