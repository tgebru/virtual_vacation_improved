//
//  FlickerRecentPhotosFromPlaceViewController.m
//  TopPlaces
//
//  Created by timnit gebru on 7/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.

//Download a certain number of pictures specified by MAX_RESULTS from Flickr

#import "FlickerRecentPhotosFromPlaceViewController.h"
#import "Cache.h"
#import "FlickrFetcher.h"
#import "FlickrSinglePhotoViewController.h"
#import "FlickrPhotoAnnotation.h"
//#import "MapViewController.h"

#define MAX_RESULTS 50
#define RECENTS_VIEWCONTROLLER @"Recent Photos"

@interface FlickerRecentPhotosFromPlaceViewController()
@property (nonatomic, strong) UIImage *photoImage;
//@property (nonatomic, strong) NSArray *photos; //an array of flicker photo dictionaries
@property (nonatomic, strong) NSDictionary *photoForAnnotation;
//@property (nonatomic, strong) NSDictionary *place;
@property (nonatomic, strong) Cache *flickrPhotoCache;
@property (nonatomic, strong) NSNumber *isRecentlyViewedPhotos;
@property (nonatomic, strong) NSNumber *visited;

@end

@implementation FlickerRecentPhotosFromPlaceViewController
@synthesize photoImage = _photoImage;
@synthesize place = _place;
@synthesize photos = _photos;
@synthesize flickrPhotoCache = _flickrPhotoCache;
@synthesize photoForAnnotation = _photoForAnnotation;
@synthesize isRecentlyViewedPhotos = _isRecentlyViewedPhotos;
@synthesize visited= _visited;

#pragma mark - View lifecycle


- (void) showSpinner
{
    //Show a spinner to indicate that photos are getting downloaded
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [spinner startAnimating];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
}


- (IBAction)goToMap:(id)sender {       
    if ( self.isRecentlyViewedPhotos)self.visited =[NSNumber numberWithBool:YES];
    [self performSegueWithIdentifier:@"toMapFromListOfPhotos" sender:sender];
}

- (void) initializeCache
{
    self.flickrPhotoCache = [[Cache alloc]init];
    [self.flickrPhotoCache getCache];
}

- (void)setPhotos:(NSArray *)photos
{
    if (_photos != photos){
        _photos = photos;
        [self.tableView reloadData];
    }
}

- (void)setPlaceForPhotos: (NSDictionary *)place 
{
    self.place = place ;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
     self.navigationController.toolbarHidden=NO;   
    [self initializeCache];
    
    if ( [self.navigationController.tabBarItem.title isEqualToString:RECENTS_VIEWCONTROLLER]){
        self.isRecentlyViewedPhotos = [NSNumber numberWithBool:YES];
        NSArray *photos = [[NSUserDefaults standardUserDefaults] objectForKey:RECENTS_KEY];
        self.photos = photos;

    }else {
         self.isRecentlyViewedPhotos = [NSNumber numberWithBool:NO];
        [self showSpinner];
        
        //Fork a thread to download photos
        dispatch_queue_t flickrDownloaderQueue = dispatch_queue_create("flickr downloader", NULL);
        dispatch_async(flickrDownloaderQueue, ^{
            NSArray *photos = [FlickrFetcher photosInPlace:self.place maxResults:MAX_RESULTS];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.photos = photos;
                self.navigationItem.rightBarButtonItem = nil;
            });
        });
        
        dispatch_release(flickrDownloaderQueue);    
    }
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    self.navigationController.toolbarHidden=NO;   
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.photos count];
}

#pragma mark - Table view delegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier;    
    CellIdentifier = @"Flickr Photos For Place";
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

//Get Annotations for mapView
- (NSArray *)mapAnnotations
{
    NSMutableArray *annotations = [NSMutableArray arrayWithCapacity:[self.photos count]];
    for (NSDictionary *photo in self.photos) {
        [annotations addObject:[FlickrPhotoAnnotation annotationForPhoto:photo]];
    }
    return annotations;
}

- (void) saveToNSDefaults:(NSDictionary *)photo
{
    //save to NSUserDefaults     
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *recents = [[defaults objectForKey:RECENTS_KEY] mutableCopy];
    if (!recents) recents = [NSMutableArray array];
    
    //If the photo is stored already remove it
    NSString *photoID = [photo objectForKey: @"id"];
    for (int i=0; i<[recents count] ; i++){
        NSDictionary *photo = [self.photos objectAtIndex:i];
        if ([[photo objectForKey:@"id"] isEqualToString:photoID]){
            [recents removeObject:photo];
        }
    }
    
    if ([recents count] == MAX_RESULTS){
        [recents removeObjectAtIndex:MAX_RESULTS-1];
    }
    
    [recents addObject:photo];
    [defaults setObject:recents forKey:RECENTS_KEY];
    [defaults synchronize];
    
    NSLog (@"done saving to defaults");
}

#pragma mark - MapViewControllerDelegate

- (UIImage *)mapViewController:(MapViewController *)sender imageForAnnotation:(id <MKAnnotation>)annotation
{
    NSData *data;
  
    FlickrPhotoAnnotation *fpa = (FlickrPhotoAnnotation *)annotation;
    NSURL *url = [FlickrFetcher urlForPhoto:fpa.photo format:FlickrPhotoFormatSquare];
    data = [NSData dataWithContentsOfURL:url];
    NSLog (@"got Thumbnail");

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

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSDictionary *photo;
    //NSLog(@"prepare for segue %@", [sender stringValue]);
    if ([sender isKindOfClass:[UIBarButtonItem class]]){      
        [segue.destinationViewController setDelegate:self];
        [segue.destinationViewController setAnnotations:[self mapAnnotations]];
        
    }else{
        if ([sender isKindOfClass:[MapViewController class]]){
            photo = self.photoForAnnotation;
        }else{
            photo = [self.photos objectAtIndex:[[self.tableView indexPathForSelectedRow] row]];
        }
        NSLog(@"inside prepareForSegue");
    
        //Fork a thread to download photos
        dispatch_queue_t downloadQueue = dispatch_queue_create("flickr downloader", NULL);
        //[self showSpinner];  
        dispatch_async(downloadQueue, ^{
            NSURL    *photoUrl;
            NSData   *imageData;
            NSString *urlString;
                    
            //NSLog(@"Just started thread");
            if ([self.flickrPhotoCache isInCache:photo]){
                urlString= [self.flickrPhotoCache readImageFromCache:photo];
                imageData = [NSData dataWithContentsOfFile:urlString];
            }else {
                photoUrl = [FlickrFetcher urlForPhoto:photo format:FlickrPhotoFormatLarge];
                imageData = [NSData dataWithContentsOfURL:photoUrl];   
            }
            //NSLog(@"Downloaded Image: %d", [imageData length]);
            dispatch_async(dispatch_get_main_queue(), ^{            
                self.photoImage= [UIImage imageWithData:imageData];
                //NSLog(@"Downloaded Image height: %f", [self.photoImage size].height);
            
                if (!self.isRecentlyViewedPhotos.boolValue){
                    //Save photo to cache
                    [self.flickrPhotoCache writeImageToCache:imageData forPhoto:photo fromUrl:photoUrl]; //update photo cache
                    NSLog(@"done caching");
                    //save to NSUserDefaults  
                    [self saveToNSDefaults:photo];
                }
                self.navigationItem.rightBarButtonItem = nil;
                if (self.visited) [segue.destinationViewController setVisitedPic: [NSNumber numberWithBool:YES]];
                [segue.destinationViewController setImage:self.photoImage forPhotoDictionary:photo];
               
            });
        });
    
        dispatch_release(downloadQueue);
    }
    NSLog(@"done preparing");
}

@end
