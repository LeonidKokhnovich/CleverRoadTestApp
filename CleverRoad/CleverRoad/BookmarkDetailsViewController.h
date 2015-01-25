//
//  BookmarkDetailsViewController.h
//  CleverRoad
//
//  Created by Admin on 1/26/15.
//  Copyright (c) 2015 leonidkokhnovych. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Bookmark;

@interface BookmarkDetailsViewController : UIViewController

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) Bookmark *bookmark;

@end
