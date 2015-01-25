//
//  MapViewController.m
//  CleverRoad
//
//  Created by Admin on 1/25/15.
//  Copyright (c) 2015 leonidkokhnovych. All rights reserved.
//

#import "AppDelegate.h"
#import "Bookmark.h"
#import "BookmarksTableViewController.h"
#import "MapViewController.h"
#import <WYStoryboardPopoverSegue.h>

typedef NS_ENUM(NSUInteger, MapViewState) {
    MapViewStateNone,
    MapViewStateBookmarks,
    MapViewStateRoute
};

#define METERS_PER_MILE 1609.344

#define kSegueNameChooseDestionation @"Choose destination"
#define kSegueNameShowBookmarks @"Show bookmarks"

@interface MapViewController () <BookmarksTableViewControllerDelegate, CLLocationManagerDelegate, MKMapViewDelegate, NSFetchedResultsControllerDelegate, WYPopoverControllerDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *leftBarButton;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (nonatomic) MapViewState mapViewState;
@property (strong, nonatomic) MKRoute *route;
@property (strong, nonatomic) Bookmark *routeDestionationBookmark;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (strong, nonatomic) WYPopoverController *bookmarksTableViewController;

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
    
    self.mapViewState = MapViewStateBookmarks;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}


#pragma mark -
#pragma mark Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:kSegueNameChooseDestionation]) {
        BookmarksTableViewController *bookmarksTableViewController = [segue destinationViewController];
        bookmarksTableViewController.delegate = self;
        bookmarksTableViewController.fetchedResultsController = self.fetchedResultsController;
        
        WYStoryboardPopoverSegue* popoverSegue = (WYStoryboardPopoverSegue*)segue;
        
        self.bookmarksTableViewController = [popoverSegue popoverControllerWithSender:sender
                                                        permittedArrowDirections:WYPopoverArrowDirectionAny
                                                                        animated:YES];
        self.bookmarksTableViewController.popoverLayoutMargins = UIEdgeInsetsMake(40, 40, 40, 40);
    }
    else if ([segue.identifier isEqualToString:kSegueNameShowBookmarks]) {
        BookmarksTableViewController *bookmarksTableViewController = [segue destinationViewController];
        bookmarksTableViewController.fetchedResultsController = self.fetchedResultsController;
    }
}


#pragma mark -
#pragma mark User Actions

- (IBAction)leftBarButtonTapped:(id)sender
{
    NSLog(@"Left bar button tapped");
    
    if (self.mapViewState == MapViewStateRoute) {
        self.mapViewState = MapViewStateBookmarks;
    }
    else if (self.mapViewState == MapViewStateBookmarks) {
        [self performSegueWithIdentifier:kSegueNameChooseDestionation sender:self.leftBarButton];
    }
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
    CLLocation *location = [[CLLocation alloc] initWithLatitude:touchMapCoordinate.latitude longitude:touchMapCoordinate.longitude];
    
    // Store new annotation
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Bookmark" inManagedObjectContext:self.managedObjectContext];
    Bookmark *bookmark = [[Bookmark alloc] initWithEntity:entity insertIntoManagedObjectContext:self.managedObjectContext];
    bookmark.location = location;
    bookmark.date = [NSDate date];
    
    // Save the context.
    NSError *error = nil;
    if (![context save:&error]) {
#warning TODO: need to process error
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
}


#pragma mark -
#pragma mark Accessory Methods

- (NSManagedObjectContext *)managedObjectContext
{
    if (!_managedObjectContext) {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        _managedObjectContext = appDelegate.managedObjectContext;
    }
    return _managedObjectContext;
}

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Bookmark"
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *nameSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:NO];
    NSSortDescriptor *dateSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
    NSArray *sortDescriptors = @[nameSortDescriptor, dateSortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                    managedObjectContext:self.managedObjectContext
                                                                      sectionNameKeyPath:nil
                                                                               cacheName:nil];
    _fetchedResultsController.delegate = self;
    
    NSError *error = nil;
    if (![_fetchedResultsController performFetch:&error]) {
#warning TODO: need to process error
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    
    return _fetchedResultsController;
}

- (void)setMapViewState:(MapViewState)mapViewState
{
    if (_mapViewState != mapViewState) {
        _mapViewState = mapViewState;
        
        if (self.mapViewState == MapViewStateBookmarks) {
            [self.mapView removeOverlay:self.route.polyline];
            
            for (Bookmark *bookmark in self.fetchedResultsController.fetchedObjects) {
                [self addPointAnnotationToMapViewWithBookmark:bookmark];
            }
            
            self.leftBarButton.title = NSLocalizedString(@"Route", nil);
        }
        else {
            NSAssert(self.routeDestionationBookmark != nil, @"Destination is not specified.");
            
            [self.mapView removeAnnotations:self.mapView.annotations];
            [self addPointAnnotationToMapViewWithBookmark:self.routeDestionationBookmark];
            
            // Create route between current location and selected point annotation
            MKDirectionsRequest *directionsRequest = [[MKDirectionsRequest alloc] init];
            MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:self.routeDestionationBookmark.location.coordinate addressDictionary:nil];
            [directionsRequest setSource:[MKMapItem mapItemForCurrentLocation]];
            [directionsRequest setDestination:[[MKMapItem alloc] initWithPlacemark:placemark]];
            directionsRequest.transportType = MKDirectionsTransportTypeAutomobile;
            MKDirections *directions = [[MKDirections alloc] initWithRequest:directionsRequest];
            [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
                if (error) {
                    NSLog(@"Error %@", error.description);
                } else {
                    self.route = response.routes.lastObject;
                    [self.mapView addOverlay:self.route.polyline];
                }
            }];
            
            self.leftBarButton.title = NSLocalizedString(@"Clear route", nil);
        }
    }
}


#pragma mark -
#pragma mark WYPopoverControllerDelegate

- (void)popoverControllerDidDismissPopover:(WYPopoverController *)aPopoverController
{
    if (self.bookmarksTableViewController == aPopoverController) {
        self.bookmarksTableViewController.delegate = nil;
        self.bookmarksTableViewController = nil;
    }
}


#pragma mark -
#pragma mark BookmarksTableViewControllerDelegate

- (void)bookmarksViewController:(BookmarksTableViewController *)controller
              didChooseBookmark:(Bookmark *)bookmark
{
    self.routeDestionationBookmark = bookmark;
    self.mapViewState = MapViewStateRoute;
    
    [self.bookmarksTableViewController dismissPopoverAnimated:YES];
    self.bookmarksTableViewController.delegate = nil;
    self.bookmarksTableViewController = nil;
}


#pragma mark -
#pragma mark CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager*)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
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
    
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, METERS_PER_MILE, METERS_PER_MILE);
    [self.mapView setRegion:viewRegion];
    
    // Since app requirements are not fully clear if we need to track user's location continiously, let's stop updating user location
    [self.locationManager stopUpdatingLocation];
}


#pragma mark -
#pragma mark MKMapViewDelegate

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    MKPolylineRenderer *routeLineRenderer = [[MKPolylineRenderer alloc] initWithPolyline:self.route.polyline];
    routeLineRenderer.strokeColor = [UIColor blueColor];
    routeLineRenderer.lineWidth = 5;
    return routeLineRenderer;
}

#pragma mark -
#pragma mark NSFetchedResultsControllerDelegate

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    NSLog(@"NSFetchedResultsControllerDelegate did change object %@, change type %d", anObject, type);
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
        {
            if ([anObject isKindOfClass:[Bookmark class]]) {
                [self addPointAnnotationToMapViewWithBookmark:anObject];
            }
        }
            break;
            
        case NSFetchedResultsChangeDelete:
        {
            if ([anObject isKindOfClass:[Bookmark class]]) {
                Bookmark *bookmark = (Bookmark *)anObject;
                
                // Let's find point annotation that corresponds to the deleted bookmark
                MKPointAnnotation *bookmarkPointAnnotation;
                
                for (MKPointAnnotation *pointAnnotation in self.mapView.annotations) {
                    if (CLCOORDINATES_EQUAL(pointAnnotation.coordinate, bookmark.location.coordinate)) {
                        bookmarkPointAnnotation = pointAnnotation;
                        break;
                    }
                }
                
                // Remove item from map view
                if (bookmarkPointAnnotation) {
                    [self.mapView removeAnnotation:bookmarkPointAnnotation];
                }
            }
        }
            break;
    }
}


#pragma mark -
#pragma mark Helper Methods

- (void)addPointAnnotationToMapViewWithBookmark:(Bookmark *)bookmark
{
    if (bookmark) {
        MKPointAnnotation *pointAnnotation = [[MKPointAnnotation alloc] init];
        pointAnnotation.coordinate = bookmark.location.coordinate;
        pointAnnotation.title = bookmark.name;
        [self.mapView addAnnotation:pointAnnotation];
    }
    else {
        NSLog(@"Could't process empty bookmark");
    }
}

@end
