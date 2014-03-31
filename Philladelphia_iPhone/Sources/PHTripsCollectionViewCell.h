//
//  PHTripsCollectionViewCell.h
//  Philladelphia_iPhone
//
//  Created by Igor Bogatchuk on 3/26/14.
//  Copyright (c) 2014 Igor Bogatchuk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PHTripsCollectionViewCell : UICollectionViewCell

@property (nonatomic, copy) NSString* departureTime;
@property (nonatomic, copy) NSString* arrivalTime;
@property (nonatomic, copy) NSString* duration;
@property BOOL isActual;

@end
