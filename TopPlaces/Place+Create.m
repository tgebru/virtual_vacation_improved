//
//  Place+Create.m
//  TopPlaces
//
//  Created by timnit gebru on 8/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Place+Create.h"
#import "FlickrFetcher.h"

@implementation Place (Create)

+ (Place *)placeWithName:(NSDictionary *)flickrInfo
                inManagedObjectContext:(NSManagedObjectContext *)context
{
    Place *place = nil;
    
    NSString *name = [flickrInfo objectForKey:FLICKR_PHOTO_PLACE_NAME];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Place"];
    request.predicate = [NSPredicate predicateWithFormat:@"name = %@", name];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *places = [context executeFetchRequest:request error:&error];
    
    if (!places || ([places count] > 1)) {
        // handle error
    } else if (![places count]) {
        place = [NSEntityDescription insertNewObjectForEntityForName:@"Place"
                                                     inManagedObjectContext:context];
      /*  
        if (name && !([name compare:@""]==NSOrderedSame)){
            place.name = name;
        }else {
            place.name = @"Unknown";
        }
       */ 
        place.name = name;
        place.unique = [flickrInfo objectForKey:FLICKR_PLACE_ID];
        NSLog(@"%@", place.unique);
        //place.date = 
    } else {
        place = [places lastObject];
    }
    
    return place;
}

@end

