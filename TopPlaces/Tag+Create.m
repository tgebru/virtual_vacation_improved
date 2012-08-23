//
//  Tag+Create.m
//  TopPlaces
//
//  Created by timnit gebru on 8/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Tag+Create.h"

@implementation Tag (Create)
+ (NSSet*)tagsWithPhoto:(Photo *)photo
    andArrayOfTagNames:(NSArray *) arrayOfTagNames
    inManagedObjectContext:(NSManagedObjectContext *)context

{
    Tag *tag= nil;
    NSMutableSet *mutableTags= [[NSMutableSet alloc]init];
    NSSet *tags = [[NSSet alloc]init];
    
    for (NSString *name in arrayOfTagNames){
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Tag"];
        request.predicate = [NSPredicate predicateWithFormat:@"title = %@", name];
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
        request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        
        NSError *error = nil;
        NSArray *tagsArray = [context executeFetchRequest:request error:&error];
        
        if (!tagsArray || ([tagsArray count] > 1)) {
            // handle error
        } else if (![tagsArray count]) {
            tag = [NSEntityDescription insertNewObjectForEntityForName:@"Tag"
                                                inManagedObjectContext:context];
            tag.title = name;
            tag.photos = [tag.photos setByAddingObject:photo];
            [mutableTags addObject:tag];
        } else {
            tag = [tagsArray lastObject];
            [mutableTags addObject:tag];
        }
        
    }
    
    tags = [NSSet setWithSet:mutableTags];
    return tags;
}

@end
