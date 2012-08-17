//
//  Photo+Delete.m
//  TopPlaces
//
//  Created by timnit gebru on 8/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Photo+Delete.h"
#import "FlickrFetcher.h"
#import "Place.h"

@implementation Photo (Delete)


+ (void)deleteWithFlickrInfo:(NSDictionary *)flickrInfo
        inManagedObjectContext:(NSManagedObjectContext *)context
{
    Photo *photo = nil;
    Place *place = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    request.predicate = [NSPredicate predicateWithFormat:@"unique = %@", [flickrInfo objectForKey:FLICKR_PHOTO_ID]];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || ([matches count] > 1)) {
        // handle error
         NSLog(@"%s: Didn't delete anything. More than one photo was returned.", __FUNCTION__);
    } else if ([matches count] == 1) {
        photo = [matches lastObject];
        [context deleteObject:photo];
    } else {
        NSLog(@"%s: Didn't delete anything. No photo was returned.", __FUNCTION__);
    }
    
    //Check to see if number of photos taken at place is now zero and then delete place
    NSFetchRequest *placeRequest = [NSFetchRequest fetchRequestWithEntityName:@"Place"];
    placeRequest.predicate =  request.predicate = [NSPredicate predicateWithFormat:@"unique = %@", [flickrInfo objectForKey:FLICKR_PLACE_ID]];
    NSSortDescriptor *placeSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    placeRequest.sortDescriptors = [NSArray arrayWithObject:placeSortDescriptor];
    NSArray *placeMatches = [context executeFetchRequest:placeRequest error:&error];
    
    if (!placeMatches || ([placeMatches count] > 1)) {
        // handle error
        NSLog(@"%s: Didn't delete anything. More than one photo was returned.", __FUNCTION__);
    } else if ([placeMatches count] == 1) {
        place = [placeMatches lastObject];
        NSLog(@"%@, %d", place.name, [place.photos count]);
        if ([place.photos count] ==0) {
            [context deleteObject:place];
        }
    } else {
        NSLog(@"%s: Didn't delete anything. No place was returned.", __FUNCTION__);
    }
}

@end
