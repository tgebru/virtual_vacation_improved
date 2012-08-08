//
//  FlickerPhotosViewController.h
//  TopPlaces
//
//  Created by timnit gebru on 7/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FlickerPhotosViewController : UITableViewController 
#define RECENTS_KEY @"Recent Photos"
@property (nonatomic, strong) NSArray *photos; //an array of flicker photo dictionaries
//- (void) showSpinner;
//- (void)setPhotos:(NSArray *)photos;
@end

