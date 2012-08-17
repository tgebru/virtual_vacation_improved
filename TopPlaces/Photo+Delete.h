//
//  Photo+Delete.h
//  TopPlaces
//
//  Created by timnit gebru on 8/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Photo.h"

@interface Photo (Delete)

+ (void)deleteWithFlickrInfo:(NSDictionary *)flickrInfo
        inManagedObjectContext:(NSManagedObjectContext *)context;



@end
