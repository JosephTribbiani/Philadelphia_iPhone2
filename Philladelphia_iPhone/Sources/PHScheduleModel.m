//
//  PHScheduleModel.m
//  Philladelphia_iPhone
//
//  Created by Igor Bogatchuk on 3/27/14.
//  Copyright (c) 2014 Igor Bogatchuk. All rights reserved.
//

#import "PHScheduleModel.h"
#import "PHStation+Utils.h"
#import "PHTrain.h"

#define kForwardsDirection @"0"

@implementation PHScheduleModel

- (id)init
{
    self = [super init];
    if (self)
    {
        _selectedTime = [self currentHour];
        _selectedDay = [self currentDayOfWeek];
        
        [self addKeyValueObservers];
    }
    return self;
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"selectedTime"];
    [self removeObserver:self forKeyPath:@"selectedDay"];
    [self removeObserver:self forKeyPath:@"fromStation"];
    [self removeObserver:self forKeyPath:@"toStation"];
}

- (void)addKeyValueObservers
{
    [self addObserver:self forKeyPath:@"selectedTime" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"selectedDay" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"fromStation" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"toStation" options:NSKeyValueObservingOptionNew context:nil];
}

- (NSInteger)currentHour
{
    NSDateFormatter* formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"H"];
    NSString* hourString = [formatter stringFromDate:[NSDate date]];
    return [hourString integerValue];
}

- (NSTimeInterval)currentTimeIntervalSinceMidnight
{
    NSDate* currentDate = [NSDate date];
    NSCalendar* calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents* components = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:currentDate];
    NSDate* midnightDate = [calendar dateFromComponents:components];
    return [currentDate timeIntervalSinceDate:midnightDate];
}

- (NSInteger)currentDayOfWeek
{
    NSCalendar* calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents* components = [calendar components:NSCalendarUnitWeekday fromDate:[NSDate date]];
    NSInteger currentDay = [components weekday];
    if (currentDay == 1)
    {
        currentDay = 2;
    }
    else if (currentDay == 7)
    {
        currentDay = 1;
    }
    else
    {
        currentDay = 0;
    }
    return currentDay;
}

- (NSInteger)dayFromSelectedDay
{
    NSInteger day = 0;
    if (self.selectedDay == 2)
    {
        day = 6;
    }
    else if (self.selectedDay == 1)
    {
        day = 5;
    }
    else
    {
        day = 0;
    }
    return day;
}

- (NSArray *)weekDays
{
    if (_weekDays == nil)
    {
        _weekDays = @[@"WEEKDAYS", @"SATURDAY", @"SUNDAY"];
    }
    return _weekDays;
}

- (NSArray *)hours
{
    if (_hours == nil)
    {
        NSMutableArray* mutableHours = [NSMutableArray new];
        for (NSUInteger i = 0; i < 24; i++)
        {
            NSDateFormatter* formatter = [NSDateFormatter new];
            [formatter setDateFormat:@"HH"];
            NSDate* date = [formatter dateFromString:[NSString stringWithFormat:@"%d",i]];
            [formatter setDateFormat:@"h a"];
            NSString* dateString = [formatter stringFromDate:date];
            [mutableHours addObject:dateString];
        }
        _hours = [NSArray arrayWithArray:mutableHours];
    }
    return _hours;
}

- (NSArray*)trips
{
    if (_trips == nil)
    {
        _trips = [self trainsFromStation:self.fromStation toStation:self.toStation];
    }
    return _trips;
}

#pragma mark - Calculations

- (NSArray*)trainsFromStation:(PHStation*)startStation toStation:(PHStation*)stopStation
{
    NSMutableArray* result = [NSMutableArray new];
    
    NSSet* startStationTrains = [startStation passingTrains];
    NSSet* stopStationTrains = [stopStation passingTrains];
    
    NSMutableSet* crossTrains = [startStationTrains mutableCopy];
    [crossTrains intersectSet:stopStationTrains];
    
    for (PHTrain* train in crossTrains)
    {
        if ([self directionForLine:train.line startStation:startStation stopStation:stopStation] == [train.direction boolValue])
        {
            NSArray* schedules = [NSJSONSerialization JSONObjectWithData:train.schedule options:0 error:NULL];
            for (NSDictionary* schedule in schedules)
            {
                NSString* days = schedule[@"days"];
                NSRange dayRange = [days rangeOfString:[NSString stringWithFormat:@"%d", [self dayFromSelectedDay]]];
                if (dayRange.location != NSNotFound)
                {
                    NSArray* startTimes = [schedule[@"schedule"] objectForKey:startStation.stopId];
                    NSArray* endTimes = [schedule[@"schedule"] objectForKey:stopStation.stopId];
                    NSUInteger index = 0;
                    for (NSNumber* time in startTimes)
                    {
                        BOOL isActual = [self currentTimeIntervalSinceMidnight] < [time floatValue];
                        if ([time floatValue] > [self lowerBoundForHour:self.selectedTime] && [time floatValue] < [self upperBoundForHour:self.selectedTime])
                        {
                            NSString* duration = [self durationForDepartureTime:[time floatValue] arrivalTime:[[endTimes objectAtIndex:index] floatValue]];
                            NSString* startTime = [self stringFromTimeInterval:[time floatValue]];
                            NSString* endTime = [self stringFromTimeInterval:[[endTimes objectAtIndex:index] floatValue]];
                            NSNumber* isActualNumber = @(isActual);
                            
                            [result addObject:@{@"duration" : duration,
                                                @"startTime" : startTime,
                                                @"endTime" : endTime,
                                                @"isActual" : isActualNumber}];
                        }
                        index++;
                    }
                }
            }
        }
    }
    
    [result sortUsingComparator:^NSComparisonResult(NSDictionary* time1, NSDictionary* time2)
     {
         return [[time1 objectForKey:@"startTime"] compare:[time2 objectForKey:@"startTime"]];
     }];
    
    return [result count] == 0 ? nil : [NSArray arrayWithArray:result];
}

- (BOOL)directionForLine:(PHLine*)line startStation:(PHStation*)startStation stopStation:(PHStation*)stopStation
{
    NSDictionary* startStationPositions = [[NSJSONSerialization JSONObjectWithData:startStation.positions options:0 error:NULL] objectForKey:line.lineId];
    NSInteger startStationDirectPosition = [[startStationPositions objectForKey:kForwardsDirection] integerValue];
    
    NSDictionary* stopStationPositions = [[NSJSONSerialization JSONObjectWithData:stopStation.positions options:0 error:NULL] objectForKey:line.lineId];
    NSInteger stopStationDirectPosition = [[stopStationPositions objectForKey:kForwardsDirection] integerValue];
    
    if (startStationDirectPosition < stopStationDirectPosition)
    {
        return NO;
    }
    else
    {
        return YES;
    }
}

- (NSString*)stringFromTimeInterval:(NSTimeInterval)timeInterval
{
    NSInteger integerTimeInterval = (NSInteger)timeInterval;
    NSInteger minutes = (integerTimeInterval / 60) % 60;
    NSInteger hours = (integerTimeInterval / 3600) % 24;
    NSDateFormatter* formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"HH:mm"];
    NSDate* date = [formatter dateFromString:[NSString stringWithFormat:@"%02i:%02i", hours, minutes]];
    [formatter setDateFormat:@"hh:mm a"];
    return [formatter stringFromDate:date];
}

- (NSString*)durationForDepartureTime:(NSTimeInterval)departureTime arrivalTime:(NSTimeInterval)arrivalTime
{
    NSTimeInterval durationInterval = arrivalTime - departureTime;
    NSInteger integerdurationInterval = (NSInteger)durationInterval;
    NSInteger minutes = integerdurationInterval / 60;
    NSString* result = [NSString stringWithFormat:@"%d\nMIN",minutes];
    return result;
}

- (NSTimeInterval)lowerBoundForHour:(NSInteger)hour
{
    return hour * 3600.0;
}

- (NSTimeInterval)upperBoundForHour:(NSInteger)hour
{
    return (hour + 1) * 3600 - 1;
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"selectedTime"] || [keyPath isEqualToString:@"selectedDay"] || [keyPath isEqualToString:@"fromStation"] || [keyPath isEqualToString:@"toStation"])
    {
        if ((self.fromStation != nil && self.toStation != nil))
        {
            _trips = nil;
            [self.delegate shouldUpdateTrips];
        }
    }
}

@end
