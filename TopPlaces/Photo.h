//
//  Photo.h
//  TopPlaces
//
//  Created by timnit gebru on 8/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Place;

@interface Photo : NSManagedObject

@property (nonatomic, retain) NSString * imageUrl;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * unique;
@property (nonatomic, retain) NSNumber * visited;
@property (nonatomic, retain) NSSet *tagName;
@property (nonatomic, retain) Place *takenAt;
@end

@interface Photo (CoreDataGeneratedAccessors)

- (void)addTagNameObject:(NSManagedObject *)value;
- (void)removeTagNameObject:(NSManagedObject *)value;
- (void)addTagName:(NSSet *)values;
- (void)removeTagName:(NSSet *)values;
@end
