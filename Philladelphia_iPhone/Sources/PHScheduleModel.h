//
//  PHScheduleModel.h
//  Philladelphia_iPhone
//
//  Created by Igor Bogatchuk on 3/27/14.
//  Copyright (c) 2014 Igor Bogatchuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PHStation.h"
#import "PHLine.h"

@protocol PHScheduleModelDelegate <NSObject>

- (void)shouldUpdateTrips;

@end

@interface PHScheduleModel : NSObject

@property (nonatomic, strong) PHLine* line;
@property (nonatomic, strong) PHStation* fromStation;
@property (nonatomic, strong) PHStation* toStation;

@property (nonatomic, assign) NSUInteger selectedDay;
@property (nonatomic, assign) NSInteger selectedTime;

//Data Source
@property (nonatomic, strong) NSArray* trips;
@property (nonatomic, strong) NSArray* weekDays;
@property (nonatomic, strong) NSArray* hours;

@property (nonatomic, weak) id<PHScheduleModelDelegate> delegate;

@end
