//
//  Cache.m
//  TopPlaces
//
//  Created by timnit gebru on 8/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Cache.h"
#import "FlickrFetcher.h"

@interface Cache()

@property (nonatomic, strong) NSArray  *photoCachePaths;
@property (nonatomic, strong) NSURL    *flickrCacheDir;
@end

@implementation Cache
@synthesize photoCachePaths = _photoCachePaths;
@synthesize flickrCacheDir  = _flickrCacheDir;

#define CACHE_MAX_SIZE 10000000
#define FLICKR_CACHE_DIR @"Flickr"

-(void) getCache 
{
    NSFileManager * fileManager = [NSFileManager defaultManager];
    NSArray *paths = [fileManager URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask];
    NSURL *cacheDir= [paths lastObject];
    
    self.flickrCacheDir = [cacheDir URLByAppendingPathComponent:FLICKR_CACHE_DIR];

    if (![fileManager contentsOfDirectoryAtPath:[self.flickrCacheDir path] error:nil]){
        //Create Flickr directory
        [fileManager createDirectoryAtURL:self.flickrCacheDir withIntermediateDirectories:NO attributes:nil error:nil];
    }
 
    self.photoCachePaths = [fileManager contentsOfDirectoryAtPath:[self.flickrCacheDir path] error:nil];
    
    //keep cache folder less than 10MB
    NSDate *earliestDate;
    NSString  *pathToDelete;
    double folderSize = 0;
    
    for (NSString *photoCachePath in self.photoCachePaths){
        NSString *path = [[self.flickrCacheDir path]stringByAppendingPathComponent:photoCachePath];
        NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:path error:nil];
        NSDate *date = [fileAttributes fileCreationDate];
        double fileSize = [fileAttributes fileSize];
        folderSize += fileSize;
        if (!earliestDate){
            earliestDate = date;
            pathToDelete = path;
        } else {
            if([date compare:earliestDate]== NSOrderedAscending){
                earliestDate = date;
                pathToDelete = path;
            }
        }        
    }
    
    if (folderSize > CACHE_MAX_SIZE) [fileManager removeItemAtPath:pathToDelete error:nil];
}

- (NSString *) getFileNameFromCache:(NSDictionary *)photo
{
    NSString *result=nil;
    for (NSString *photoCachePath in self.photoCachePaths){
        NSString *photoID = [photo objectForKey:FLICKR_PHOTO_ID];
        NSString *fileFullName = [[photoCachePath componentsSeparatedByString:@"/"] lastObject];
        NSString *fileName     = [[fileFullName componentsSeparatedByString:@"."] 
                                  objectAtIndex:0];
        if ([fileName isEqualToString:photoID]) {
            result = [[self.flickrCacheDir path]stringByAppendingPathComponent:fileFullName];
        }
    }
    return result;
}

-(BOOL)isInCache:(NSDictionary *)photo
{
    if ([self getFileNameFromCache:photo]){  
        return YES;
    }
    return NO;
}

-(NSString *) readImageFromCache: (NSDictionary *) photo
{
    return [self getFileNameFromCache:photo];
}

-(void)writeImageToCache:(NSData *)image forPhoto:(NSDictionary *)photo fromUrl:(NSURL *)url
{
    if (url){
        NSString *photoID = [photo objectForKey:FLICKR_PHOTO_ID];
        //NSString *urlString=[url absoluteString];
        NSString *photoFormat = [[[[url path] componentsSeparatedByString:@"."]lastObject]lowercaseString];
        
        NSString *fileFullName = [NSString stringWithFormat:photoID, photoFormat];    
        NSString *path = [[self.flickrCacheDir URLByAppendingPathComponent:fileFullName] path];
    
        [image writeToFile:path atomically:YES];
    }
}

@end
