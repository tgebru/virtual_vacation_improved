//
//  FlickrPhotoAnnotation.m
//  TopPlaces
//
//  Created by timnit gebru on 8/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FlickrPhotoAnnotation.h"
#import "FlickrFetcher.h"

@implementation FlickrPhotoAnnotation 

@synthesize photo = _photo;

+ (FlickrPhotoAnnotation *)annotationForPhoto:(NSDictionary *)photo
{
    FlickrPhotoAnnotation *annotation = [[FlickrPhotoAnnotation alloc] init];
    annotation.photo = photo;
    return annotation;
}

#pragma mark - MKAnnotation

- (NSString *)title

{
    if ([[self.photo allKeys] containsObject:FLICKR_PHOTO_TITLE]){

        return [self.photo objectForKey:FLICKR_PHOTO_TITLE];
    }else{    
        NSRange start = [[self.photo objectForKey:FLICKR_PLACE_NAME] rangeOfString:@","];
        if (start.location != NSNotFound)
        {
            return ([[self.photo objectForKey:FLICKR_PLACE_NAME] substringToIndex:start.location]);
        }
    }
    return @"Unknown";
}

- (NSString *)subtitle
{
    if ([[self.photo allKeys] containsObject:FLICKR_PHOTO_DESCRIPTION]){
        return [self.photo valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
    } else {
        NSRange start = [[self.photo objectForKey:FLICKR_PLACE_NAME] rangeOfString:@","];
        if (start.location != NSNotFound)
        {
            return([[self.photo objectForKey:FLICKR_PLACE_NAME] substringFromIndex:start.location + start.length]);
        }
    }
    return @"Unknown";   
}

- (CLLocationCoordinate2D)coordinate
{
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = [[self.photo objectForKey:FLICKR_LATITUDE] doubleValue];
    coordinate.longitude = [[self.photo objectForKey:FLICKR_LONGITUDE] doubleValue];
    return coordinate;
}

@end