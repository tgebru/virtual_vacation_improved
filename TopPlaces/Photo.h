//
//  Photo.h
//  TopPlaces
//
//  Created by timnit gebru on 8/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Place, Tag;

@interface Photo : NSManagedObject

@property (nonatomic, retain) NSString * imageUrl;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * visited;
@property (nonatomic, retain) NSString * unique;
@property (nonatomic, retain) Tag *tagName;
@property (nonatomic, retain) Place *takenAt;

@end
