//
//  Photo+Create.m
//  TopPlaces
//
//  Created by timnit gebru on 8/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Photo+Create.h"
#import "FlickrFetcher.h"
#import "Tag+Create.h"
#import "Place+Create.h"

@implementation Photo (Create)

+ (Photo *)photoWithFlickrInfo:(NSDictionary *)flickrInfo
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
    } else if ([matches count] == 0) {
        photo = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:context];
        photo.unique = [flickrInfo objectForKey:FLICKR_PHOTO_ID];
        NSString *title = [flickrInfo objectForKey:FLICKR_PHOTO_TITLE];
        if (title && ![title compare:@""]==NSOrderedSame){
            photo.title = [flickrInfo objectForKey:FLICKR_PHOTO_TITLE];
        } else {
            photo.title = @"Unknown";
        }
        //photo.subtitle = [flickrInfo valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
        photo.imageUrl = [[FlickrFetcher urlForPhoto:flickrInfo format:FlickrPhotoFormatLarge] absoluteString];
        photo.takenAt = [Place placeWithName:flickrInfo inManagedObjectContext:context];
        
        //Get Photo Tags from Flickr (they are separated by space)
        NSArray *tags = [[flickrInfo objectForKey:FLICKR_TAGS]componentsSeparatedByString:@" "];
        NSMutableArray *tagsWithCapFirstLetter = [[NSMutableArray alloc]initWithCapacity:[tags count]];
        
        int i=0;
        for (NSString *tag in tags){
            if ([tag rangeOfString:@":"].location == NSNotFound){
                NSString *tagWithCapFirstLetter = [[tag lowercaseString] stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[tag substringToIndex:1] uppercaseString]];
                [tagsWithCapFirstLetter insertObject:tagWithCapFirstLetter atIndex:i];
                i++;        
                NSLog(@"%@", tagWithCapFirstLetter);
            }
        }
          
        photo.tagName = [Tag tagsWithPhoto:photo 
                        andArrayOfTagNames:tagsWithCapFirstLetter
                        inManagedObjectContext:context];
      
        photo.visited = [NSNumber numberWithBool:YES];
        
    } else {
        photo = [matches lastObject];
    }
    
    return photo;
}

@end
