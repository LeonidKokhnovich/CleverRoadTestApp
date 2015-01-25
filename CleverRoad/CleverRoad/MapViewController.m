//
//  MapViewController.m
//  CleverRoad
//
//  Created by Admin on 1/25/15.
//  Copyright (c) 2015 leonidkokhnovych. All rights reserved.
//

#import "AppDelegate.h"
#import "Bookmark.h"
#import "MapViewController.h"

typedef NS_ENUM(NSUInteger, MapViewState) {
    MapViewStateBookmarks, // initialization for free
    MapViewStateRoute
};

#define METERS_PER_MILE 1609.344

@interface MapViewController () <CLLocationManagerDelegate, MKMapViewDelegate, NSFetchedResultsControllerDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *leftBarButton;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (nonatomic) MapViewState mapViewState;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

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

    for (Bookmark *bookmark in self.fetchedResultsController.fetchedObjects) {
        [self addPointAnnotationToMapViewWithBookmark:bookmark];
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
