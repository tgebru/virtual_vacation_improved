//
//  Tag+Create.h
//  TopPlaces
//
//  Created by timnit gebru on 8/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Tag.h"
#import "Photo.h"

@interface Tag (Create)
/*
+ (Tag *)tagWithName:(NSString *)name
  inManagedObjectContext:(NSManagedObjectContext *)context;
*/
+ (NSSet *)tagsWithPhoto:(Photo *)photo
  andArrayOfTagNames:(NSArray *) tagsWithCapFirstLetter
  inManagedObjectContext:(NSManagedObjectContext *)context;

@end
