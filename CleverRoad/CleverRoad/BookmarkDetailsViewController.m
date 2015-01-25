//
//  BookmarkDetailsViewController.m
//  CleverRoad
//
//  Created by Admin on 1/26/15.
//  Copyright (c) 2015 leonidkokhnovych. All rights reserved.
//

#import "AppDelegate.h"
#import "Bookmark.h"
#import "BookmarkDetailsViewController.h"

@interface BookmarkDetailsViewController () <UIAlertViewDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *loadNearbyPlacesButton;
@property (weak, nonatomic) IBOutlet UITableView *nearbyPlacesTableView;

@end

@implementation BookmarkDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = self.bookmark.name ? : NSLocalizedString(@"No name", nil);
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
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}


#pragma mark -
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}


@end
