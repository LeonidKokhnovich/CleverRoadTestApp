//
//  BookmarksTableViewController.h
//  CleverRoad
//
//  Created by Admin on 1/25/15.
//  Copyright (c) 2015 leonidkokhnovych. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Bookmark;
@class BookmarksTableViewController;

@protocol BookmarksTableViewControllerDelegate <NSObject>

- (void)bookmarksViewController:(BookmarksTableViewController *)controller
              didChooseBookmark:(Bookmark *)bookmark;

@end

@interface BookmarksTableViewController : UITableViewController

@property (weak, nonatomic) id <BookmarksTableViewControllerDelegate> delegate;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@end
