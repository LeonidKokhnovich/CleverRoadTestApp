//
//  BookmarksTableViewController.m
//  CleverRoad
//
//  Created by Admin on 1/25/15.
//  Copyright (c) 2015 leonidkokhnovych. All rights reserved.
//

#import "Bookmark.h"
#import "BookmarksTableViewController.h"

@interface BookmarksTableViewController ()

@end

@implementation BookmarksTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.fetchedResultsController.fetchedObjects count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
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
    
    [self.delegate bookmarksViewController:self didChooseBookmark:bookmark];
}

@end
