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
#import "FlickrPhotoAnnotation.h"
#import "MapViewController.h"
#import "FlickrSinglePhotoViewController.h"


#define MAX_RESULTS 50

@interface FlickrRecentPhotosViewController()
@property (nonatomic, strong) UIImage *photoImage;
@property (nonatomic, strong) NSArray *photos; //an array of flicker photo dictionaries
@property (nonatomic, strong) Cache *flickrPhotoCache;
@property (nonatomic, strong) NSDictionary *photoForAnnotation;
@end

@implementation FlickrRecentPhotosViewController
@synthesize photoImage = _photoImage;
@synthesize photos = _photos;
@synthesize flickrPhotoCache = _flickrPhotoCache;
@synthesize photoForAnnotation = _photoForAnnotation;

- (void) showSpinner
{
    //Show a spinner to indicate that photos are getting downloaded
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [spinner startAnimating];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
}

- (IBAction)goToMap:(id)sender {
    [self performSegueWithIdentifier:@"toMapFromListOfPhotos" sender:sender];

}
- (void) viewDidLoad
{
    [super viewDidLoad];  
    self.navigationController.toolbarHidden=NO;

    self.flickrPhotoCache = [[Cache alloc]init];
    [self.flickrPhotoCache getCache];
    NSArray *photos = [[NSUserDefaults standardUserDefaults] objectForKey:RECENTS_KEY];
    self.photos = photos;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    self.navigationController.toolbarHidden=NO;

    //Refresh the photos list
    //self.photos = [[NSUserDefaults standardUserDefaults] objectForKey:RECENTS_KEY];
   
}

#pragma mark - Table view delegate

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

#pragma mark - MapViewControllerDelegate

- (UIImage *)mapViewController:(MapViewController *)sender imageForAnnotation:(id <MKAnnotation>)annotation
{
    FlickrPhotoAnnotation *fpa = (FlickrPhotoAnnotation *)annotation;
    NSURL *url = [FlickrFetcher urlForPhoto:fpa.photo format:FlickrPhotoFormatSquare];
    NSData *data = [NSData dataWithContentsOfURL:url];
    return data ? [UIImage imageWithData:data] : nil;
}

- (NSDictionary *)mapViewcontroller:(MapViewController *)sender getDataForAnnotation: (id <MKAnnotation>)annotation
{
    FlickrPhotoAnnotation *fpa = (FlickrPhotoAnnotation *)annotation;
    return fpa.photo;
}

-(void)mapViewController: (MapViewController *)sender bigPhotoForAnnotation:(id <MKAnnotation>)annotation
{
    FlickrPhotoAnnotation *fpa = (FlickrPhotoAnnotation *)annotation;
    self.photoForAnnotation = fpa.photo;
    [self performSegueWithIdentifier:@"Show Single Photo" sender:sender];
}

//Get Annotations for mapView
- (NSArray *)mapAnnotations
{
    NSMutableArray *annotations = [NSMutableArray arrayWithCapacity:[self.photos count]];
    for (NSDictionary *photo in self.photos) {
        [annotations addObject:[FlickrPhotoAnnotation annotationForPhoto:photo]];
    }
    return annotations;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{    
    NSDictionary *photo;
    if ([sender isKindOfClass:[UIBarButtonItem class]]){      
        [segue.destinationViewController setDelegate:self];
        [segue.destinationViewController setAnnotations:[self mapAnnotations]];
        
    } else {
        if ([sender isKindOfClass:[MapViewController class]]){
            photo = self.photoForAnnotation;
        } else {
            photo = [self.photos objectAtIndex:[[self.tableView indexPathForSelectedRow] row]];
        }
        [self.flickrPhotoCache getCache];
    
        //Fork a thread to download photos
        dispatch_queue_t downloadQueue = dispatch_queue_create("recent photo downloader/cacher", NULL);
        [self showSpinner];
        dispatch_async(downloadQueue, ^{
            NSURL    *photoUrl;
            NSData   *imageData;
            NSString *urlString;
            if ([self.flickrPhotoCache isInCache:photo]){
                urlString= [self.flickrPhotoCache readImageFromCache:photo];
                imageData = [NSData dataWithContentsOfFile:urlString];
            }else {
                photoUrl =[FlickrFetcher urlForPhoto:photo format:FlickrPhotoFormatLarge];
                NSLog(@"About to do dataWithContentsOfURL");
                imageData = [NSData dataWithContentsOfURL:photoUrl];
                NSLog(@"after dataWithContentsOfURL");
                [self.flickrPhotoCache writeImageToCache:imageData forPhoto:photo fromUrl:photoUrl]; //update photo cache
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"Do we seg fault here?");
                self.photoImage= [UIImage imageWithData:imageData];
                self.navigationItem.rightBarButtonItem = nil;
                //[segue.destinationViewController setImage:self.photoImage];
                [segue.destinationViewController setImage:self.photoImage forPhotoDictionary:photo];
            });
        });
    
        dispatch_release(downloadQueue);
    }
}

@end
