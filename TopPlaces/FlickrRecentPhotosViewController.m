//
//  FlickrRecentPhotosViewController.m
//  TopPlaces
//
//  Created by timnit gebru on 7/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FlickrRecentPhotosViewController.h"
//#import "FlickerRecentPhotosFromPlaceViewController.h"
#import "FlickrFetcher.h"
#import "Cache.h"


#define MAX_RESULTS 50

@interface FlickrRecentPhotosViewController()
@property (nonatomic, strong) UIImage *photoImage;
@property (nonatomic, strong) NSArray *photos; //an array of flicker photo dictionaries
@property (nonatomic, strong) Cache *flickrPhotoCache;

@end

@implementation FlickrRecentPhotosViewController
@synthesize photoImage = _photoImage;
@synthesize photos = _photos;
@synthesize flickrPhotoCache = _flickrPhotoCache;

- (void) showSpinner
{
    //Show a spinner to indicate that photos are getting downloaded
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [spinner startAnimating];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
}

- (void) viewDidLoad
{
    [super viewDidLoad];    
    self.flickrPhotoCache = [[Cache alloc]init];
    [self.flickrPhotoCache getCache];
    NSArray *photos = [[NSUserDefaults standardUserDefaults] objectForKey:RECENTS_KEY];
    self.photos = photos;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    //Refresh the photos list
    //self.photos = [[NSUserDefaults standardUserDefaults] objectForKey:RECENTS_KEY];
   
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.photos count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Flickr Photo";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    NSDictionary *photo = [self.photos objectAtIndex:indexPath.row];
    
    if ([[photo objectForKey:FLICKR_PHOTO_TITLE] length] !=0){
        cell.textLabel.text = [photo objectForKey:FLICKR_PHOTO_TITLE];
        cell.detailTextLabel.text= [photo objectForKey:FLICKR_PHOTO_DESCRIPTION];
    }else if ([[photo objectForKey:FLICKR_PHOTO_DESCRIPTION] length] !=0){
        cell.textLabel.text = [photo objectForKey:FLICKR_PHOTO_DESCRIPTION];
        cell.detailTextLabel.text= @"";
    }else {
        cell.textLabel.text = @"Unknown";
        cell.detailTextLabel.text= @"";
    }
    
    return cell;
}

#pragma mark - Table view delegate
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{    
 /*  
    NSDictionary *photo = [self.photos objectAtIndex:[[self.tableView indexPathForSelectedRow] row]];
    NSURL *photoUrl = [FlickrFetcher urlForPhoto:photo format:FlickrPhotoFormatLarge];
    NSData* imageData = [NSData dataWithContentsOfURL:photoUrl];
    self.photoImage= [UIImage imageWithData:imageData];
  */  
    
    [self showSpinner]; 
    
    //Fork a thread to download photos
    dispatch_queue_t downloadQueue = dispatch_queue_create("recent photo downloader/cacher", NULL);
    dispatch_async(downloadQueue, ^{
        NSURL    *photoUrl;
        NSData   *imageData;
        NSString *urlString;
                
        NSDictionary *photo = [self.photos objectAtIndex:[[self.tableView indexPathForSelectedRow] row]];
        Cache *flickrPhotoCache = [[Cache alloc]init];
        [flickrPhotoCache getCache];
        if ([flickrPhotoCache isInCache:photo]){
            urlString= [flickrPhotoCache readImageFromCache:photo];
            imageData = [NSData dataWithContentsOfFile:urlString];
        }else {
            photoUrl =[FlickrFetcher urlForPhoto:photo format:FlickrPhotoFormatLarge];
            NSLog(@"About to do dataWithContentsOfURL");
            imageData = [NSData dataWithContentsOfURL:photoUrl];
            NSLog(@"after dataWithContentsOfURL");
            [flickrPhotoCache writeImageToCache:imageData forPhoto:photo fromUrl:photoUrl]; //update photo cache
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"Do we seg fault here?");
            self.photoImage= [UIImage imageWithData:imageData];
            self.navigationItem.rightBarButtonItem = nil;
            [segue.destinationViewController setImage:self.photoImage];
        });
    });
    
    dispatch_release(downloadQueue);
}

@end
