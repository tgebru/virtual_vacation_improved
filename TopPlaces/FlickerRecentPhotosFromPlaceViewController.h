//
//  FlickerRecentPhotosFromPlaceViewController.h
//  TopPlaces
//
//  Created by timnit gebru on 7/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapViewController.h"

#define MAX_RESULTS 50
#define RECENTS_KEY @"Recent Photos"

@interface FlickerRecentPhotosFromPlaceViewController : UITableViewController 

@property (nonatomic, strong) NSDictionary *place;
@property (nonatomic, strong) NSArray *photos; //an array of flicker photo dictionaries

//- (void)setPhotos:(NSArray *)photos;
- (void)setPlaceForPhotos:(NSDictionary *)place;
- (void) showSpinner;
- (NSArray *)mapAnnotations;
- (NSDictionary *)mapViewcontroller:(MapViewController *)sender getDataForAnnotation: (id <MKAnnotation>)annotation;
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;

@end
