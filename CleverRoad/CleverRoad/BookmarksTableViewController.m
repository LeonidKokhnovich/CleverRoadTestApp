//
//  BookmarksTableViewController.m
//  CleverRoad
//
//  Created by Admin on 1/25/15.
//  Copyright (c) 2015 leonidkokhnovych. All rights reserved.
//

#import "AppDelegate.h"
#import "Bookmark.h"
#import "BookmarkDetailsViewController.h"
#import "BookmarksTableViewController.h"

#define kSegueNameShowBookmarkDetails @"Show bookmark details"

@interface BookmarksTableViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *bookmarksTableView;

@property (strong, nonatomic) Bookmark *selectedBookmark;

@end

@implementation BookmarksTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([self isEmbededInNavigationController]) {
        self.navigationItem.rightBarButtonItem = self.editButtonItem;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.bookmarksTableView reloadData];
}


#pragma mark -
#pragma mark Navigation

 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:kSegueNameShowBookmarkDetails]) {
        BookmarkDetailsViewController *viewController = (BookmarkDetailsViewController *)segue.destinationViewController;
        viewController.bookmark = self.selectedBookmark;
        
        self.selectedBookmark = nil;
    }
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.fetchedResultsController.fetchedObjects count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cell_identifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    Bookmark *bookmark = (Bookmark *)[self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = bookmark.name ? : NSLocalizedString(@"No name", nil);
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", bookmark.location];
    
    return cell;
}


#pragma mark -
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // Let's find bookmark that corresponds to the selected cell
    Bookmark *bookmark = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    if ([self isEmbededInNavigationController]) {
        self.selectedBookmark = bookmark;
        
        // Yep, it is possible to pick bookmark as a sender, but there are some cases in which I wouldn't do that, so just store it for a moment...
        [self performSegueWithIdentifier:kSegueNameShowBookmarkDetails sender:self];
    }
    else {
        [self.delegate bookmarksViewController:self didChooseBookmark:bookmark];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NSLocalizedString(@"Remove", nil);
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        NSManagedObjectContext *context = appDelegate.managedObjectContext;
        Bookmark *bookmark = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [context deleteObject:bookmark];
        
        NSError * error = nil;
        if (![context save:&error]) {
#warning Handle error
            NSLog(@"Error ! %@", error);
        }
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
}


#pragma mark -
#pragma mark Helper Methods

- (BOOL)isEmbededInNavigationController
{
    // TODO: Refactor
    return self.navigationController ? YES : NO;
}

@end
