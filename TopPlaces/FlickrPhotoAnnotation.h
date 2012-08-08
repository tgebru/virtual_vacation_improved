//
//  FlickrPhotoAnnotation.h
//  TopPlaces
//
//  Created by timnit gebru on 8/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface FlickrPhotoAnnotation : NSObject <MKAnnotation>
    + (FlickrPhotoAnnotation *)annotationForPhoto:(NSDictionary *)photo; // Flickr photo dictionary
    @property (nonatomic, strong) NSDictionary *photo;

@end
