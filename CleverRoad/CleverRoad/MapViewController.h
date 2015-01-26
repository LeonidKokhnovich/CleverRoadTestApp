//
//  MapViewController.h
//  CleverRoad
//
//  Created by Admin on 1/25/15.
//  Copyright (c) 2015 leonidkokhnovych. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MapViewController : UIViewController

@property (strong, nonatomic) CLLocation *centerAlignmentLocation;
@property (strong, nonatomic) Bookmark *routeDestionationBookmark;

@end
