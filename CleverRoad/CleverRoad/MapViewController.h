//
//  MapViewController.h
//  CleverRoad
//
//  Created by Admin on 1/25/15.
//  Copyright (c) 2015 leonidkokhnovych. All rights reserved.
//

#import <UIKit/UIKit.h>

#define METERS_PER_MILE 1609.344

typedef NS_ENUM(NSUInteger, MapViewState) {
    MapViewStateNone,
    MapViewStateBookmarks,
    MapViewStateRoute
};

@class Bookmark;

@interface MapViewController : UIViewController

@property (strong, nonatomic) Bookmark *routeDestionationBookmark;
@property (nonatomic) MapViewState mapViewState;

- (void)setMapViewVisibleRegion:(MKCoordinateRegion)region;

@end
