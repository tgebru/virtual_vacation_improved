//
//  Cache.h
//  TopPlaces
//
//  Created by timnit gebru on 8/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Cache : NSObject
-(void) getCache;
-(BOOL)isInCache:(NSDictionary *)photo;
-(NSString *) readImageFromCache: (NSDictionary *) photo;
-(void)writeImageToCache:(NSData *) image forPhoto:(NSDictionary *)photo
                 fromUrl:(NSURL *)url;

@end
