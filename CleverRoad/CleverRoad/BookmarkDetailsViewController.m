//
//  BookmarkDetailsViewController.m
//  CleverRoad
//
//  Created by Admin on 1/26/15.
//  Copyright (c) 2015 leonidkokhnovych. All rights reserved.
//

#import <AFNetworking.h>
#import "AppDelegate.h"
#import "Bookmark.h"
#import "BookmarkDetailsViewController.h"

#define kFoursquareVenuesExploreLink @"https://api.foursquare.com/v2/venues/explore"
#define kFoursquareAppClientID @"TDX3TTDKQDCJXZQI04R552OZEO1ANHULEWPNSBZIBUZGLPL5"
#define kFoursquareAppClientSecret @"DUED44UOYTZ4FYC0WJ3WHZY3J1CTCGUCPXJZTA2E3IPNRXJB"

@interface BookmarkDetailsViewController () <UIAlertViewDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *loadNearbyPlacesButton;
@property (weak, nonatomic) IBOutlet UITableView *nearbyPlacesTableView;
@property (weak, nonatomic) IBOutlet UIView *overlayView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;

@property (strong, nonatomic) NSArray *recommendedNearbyPlaces;

@end

@implementation BookmarkDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = self.bookmark.name ? : NSLocalizedString(@"No name", nil);
    
    if (self.bookmark.name == nil) {
        [self loadNearbyPlaces];
    }
    else {
        self.overlayView.hidden = YES;
        self.nearbyPlacesTableView.hidden = YES;
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

- (IBAction)deleteButtonTapped:(id)sender
{
    NSLog(@"Delete button tapped");
    
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Delete bookmark", nil)
                                message:NSLocalizedString(@"Are you sure?", nil)
                               delegate:self
                      cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                      otherButtonTitles:NSLocalizedString(@"Ok", nil), nil] show];
}

- (IBAction)loadNearbyPlacesButtonTapped:(id)sender
{
    NSLog(@"Load nearby places button tapped");
    
    [self loadNearbyPlaces];
}

- (IBAction)centerInMapViewButtonTapped:(id)sender
{
    NSLog(@"Center in map view button tapped");
}

- (IBAction)buildRouteButtonTapped:(id)sender
{
    NSLog(@"Build route button tapped");
}


#pragma mark -
#pragma mark UIAlertViewDelegate

const int kAlertViewConfirmButtonIndex = 1;

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == kAlertViewConfirmButtonIndex) {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        NSManagedObjectContext *context = appDelegate.managedObjectContext;
        [context deleteObject:self.bookmark];
        
        NSError *error = nil;
        if (![context save:&error]) {
#warning Handle error
            NSLog(@"Error ! %@", error);
        }
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}


#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.recommendedNearbyPlaces count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellReuseIdentifier = @"cell_reuse_identifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellReuseIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifier];
    }
    
    NSDictionary *placeItemDict = [self.recommendedNearbyPlaces objectAtIndex:indexPath.row];
    NSString *placeName = [[placeItemDict objectForKey:@"venue"] objectForKey:@"name"];
    
    cell.textLabel.text = placeName;
    
    return cell;
}


#pragma mark -
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.bookmark.name == nil) {
        NSDictionary *placeItemDict = [self.recommendedNearbyPlaces objectAtIndex:indexPath.row];
        NSString *placeName = [[placeItemDict objectForKey:@"venue"] objectForKey:@"name"];
        
        self.bookmark.name = placeName;
        
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        NSManagedObjectContext *context = appDelegate.managedObjectContext;
        
        NSError *error = nil;
        if (![context save:&error]) {
#warning Handle error
            NSLog(@"Error ! %@", error);
        }
        
        self.title = self.bookmark.name;
    }
}


#pragma mark -
#pragma mark Helper Methods

NSInteger nearbyRadius = 500; // of meters
NSInteger placesLimit = 30;

- (void)loadNearbyPlaces
{
    // Prepare UI
    self.overlayView.hidden = NO;
    
    // Setup request params
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYYMMdd"];
    NSString *version = [dateFormatter stringFromDate:currentDate];
    
    NSDictionary *parameters = @{@"client_id": kFoursquareAppClientID,
                                 @"client_secret": kFoursquareAppClientSecret,
                                 @"ll": [NSString stringWithFormat:@"%f,%f", self.bookmark.location.coordinate.latitude, self.bookmark.location.coordinate.longitude],
                                 @"radius": [NSString stringWithFormat:@"%zd", nearbyRadius],
                                 @"limit": [NSString stringWithFormat:@"%zd", placesLimit],
                                 @"v": version};
    
    // Peform request
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:kFoursquareVenuesExploreLink parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        
        // Setup data source for table view
        self.recommendedNearbyPlaces = [[[[responseObject objectForKey:@"response"] objectForKey:@"groups"] firstObject] objectForKey:@"items"];
        
        // Update UI
        self.overlayView.hidden = YES;
        self.nearbyPlacesTableView.hidden = NO;
        
        [self.nearbyPlacesTableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        
        // Hide current view
        [self.navigationController popViewControllerAnimated:YES];
        
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Network error", nil)
                                    message:NSLocalizedString(@"Plase, try later", nil)
                                   delegate:nil
                          cancelButtonTitle:NSLocalizedString(@"Ok", nil)
                          otherButtonTitles:nil, nil] show];
    }];
}


@end
