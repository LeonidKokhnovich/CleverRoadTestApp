//
//  Bookmark.h
//  CleverRoad
//
//  Created by Admin on 1/25/15.
//  Copyright (c) 2015 leonidkokhnovych. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Bookmark : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) CLLocation *location;
@property (nonatomic, retain) NSDate * date;

@end
