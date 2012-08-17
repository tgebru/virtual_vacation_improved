//
//  Photo+Delete.m
//  TopPlaces
//
//  Created by timnit gebru on 8/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Photo+Delete.h"
#import "FlickrFetcher.h"

@implementation Photo (Delete)


+ (void)deleteWithFlickrInfo:(NSDictionary *)flickrInfo
        inManagedObjectContext:(NSManagedObjectContext *)context
{
    Photo *photo = nil;
    
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
}

@end
