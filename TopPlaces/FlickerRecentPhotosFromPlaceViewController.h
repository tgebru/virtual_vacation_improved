//
//  FlickerRecentPhotosFromPlaceViewController.h
//  TopPlaces
//
//  Created by timnit gebru on 7/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FlickrRecentPhotosViewController.h"

@interface FlickerRecentPhotosFromPlaceViewController :UITableViewController//: FlickerPhotosViewController
#define RECENTS_KEY @"Recent Photos"
- (void)setPlaceForPhotos: (NSDictionary *)place;
//@property (nonatomic, strong) NSDictionary *place;
//@property (nonatomic, strong) NSArray *photos; //an array of flicker photo dictionaries

@end
