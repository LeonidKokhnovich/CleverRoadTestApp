//
//  MapViewController.m
//  CleverRoad
//
//  Created by Admin on 1/25/15.
//  Copyright (c) 2015 leonidkokhnovych. All rights reserved.
//

#import "MapViewController.h"

typedef NS_ENUM(NSUInteger, MapViewState) {
    MapViewStateBookmarks, // initialization for free
    MapViewStateRoute
};

#define METERS_PER_MILE 1609.344

@interface MapViewController () <CLLocationManagerDelegate, MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *leftBarButton;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (nonatomic) MapViewState mapViewState;

@end

@implementation MapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Setup location manager
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    if (    SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")
        &&  [CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedWhenInUse)
    {
        [self.locationManager requestWhenInUseAuthorization];
    }
    else
    {
        [self.locationManager startUpdatingLocation];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


#pragma mark -
#pragma mark User Actions

- (IBAction)leftBarButtonTapped:(id)sender
{
    NSLog(@"Left bar button tapped");
}

- (IBAction)onMapViewLongTapEvent:(UILongPressGestureRecognizer *)sender
{
    if (sender.state != UIGestureRecognizerStateEnded) {
        return;
    }
    
    NSLog(@"Map view long tap event");
    
    // Let's determine the touch location coordinate
    CGPoint touchPoint = [sender locationInView:self.mapView];
    CLLocationCoordinate2D touchMapCoordinate = [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
    
    // Create new point annotation
    MKPointAnnotation *pointAnnotation = [[MKPointAnnotation alloc] init];
    pointAnnotation.coordinate = touchMapCoordinate;
    pointAnnotation.title = @"Hello";
    [self.mapView addAnnotation:pointAnnotation];
}

#pragma mark -
#pragma mark CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager*)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    NSLog(@"didChangeAuthorizationStatus");
    
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
        {
            NSLog(@"User still thinking..");
        }
            break;
            
        case kCLAuthorizationStatusDenied:
        {
            NSLog(@"User hates you");
        }
            break;
            
        case kCLAuthorizationStatusAuthorizedWhenInUse:
        case kCLAuthorizationStatusAuthorizedAlways:
        {
            NSLog(@"Cool, we are allowed to track the user");
            
            [self.locationManager startUpdatingLocation];
        }
            break;
            
        default:
            break;
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *location = [locations lastObject];
    NSLog(@"Did update location lat%f - lon%f", location.coordinate.latitude, location.coordinate.longitude);
    
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, 0.5*METERS_PER_MILE, 0.5*METERS_PER_MILE);
    [self.mapView setRegion:viewRegion];
    
    [self.locationManager stopUpdatingLocation];
}

@end
