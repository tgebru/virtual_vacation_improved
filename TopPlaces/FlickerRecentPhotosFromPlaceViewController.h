//
//  FlickerRecentPhotosFromPlaceViewController.h
//  TopPlaces
//
//  Created by timnit gebru on 7/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Cache.h"
#import "FlickrFetcher.h"
#import "FlickrSinglePhotoViewController.h"
#import "FlickrPhotoAnnotation.h"
#import "MapViewController.h"
//#import "FlickerPhotoViewController.h

#define MAX_RESULTS 50
#define RECENTS_KEY @"Recent Photos"

@interface FlickerRecentPhotosFromPlaceViewController : UITableViewController //FlickerPhotosViewController//
- (void)setPlaceForPhotos:(NSDictionary *)place;
@end
