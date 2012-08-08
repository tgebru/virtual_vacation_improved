//
//  FlickerPhotosViewController.m
//  TopPlaces
//
//  Created by timnit gebru on 7/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "FlickerPhotosViewController.h"
#import "FlickerRecentPhotosFromPlaceViewController.h"
#import "FlickrFetcher.h"
#import "FlickrPhotoAnnotation.h"
#import "MapViewController.h"

@interface FlickerPhotosViewController() <MapViewControllerDelegate>
@property (nonatomic, strong) NSDictionary *place;
//@property (nonatomic, strong) NSArray *photos; //an array of flicker photo dictionaries
@end

@implementation FlickerPhotosViewController
@synthesize photos = _photos;
@synthesize place  = _place;


- (void) showSpinner
{
    //Show a spinner to indicate that photos are getting downloaded
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [spinner startAnimating];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
}

- (IBAction)goToMap:(id)sender {
    [self performSegueWithIdentifier:@"toMapFromListOfPlaces" sender:sender];
}

- (NSArray *)mapAnnotations
{
    NSMutableArray *annotations = [NSMutableArray arrayWithCapacity:[self.photos count]];
    for (NSDictionary *photo in self.photos) {
        [annotations addObject:[FlickrPhotoAnnotation annotationForPhoto:photo]];
    }
    return annotations;
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.toolbarHidden=NO;

    [self showSpinner];   
    
    //Fork a thread to download photos
    dispatch_queue_t downloadQueue = dispatch_queue_create("flickr downloader", NULL);
    dispatch_async(downloadQueue, ^{
        NSArray *photos = [FlickrFetcher topPlaces];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.photos = photos;
            self.navigationItem.rightBarButtonItem = nil;
        });
    });
    
    dispatch_release(downloadQueue);  
}

- (void)setPhotos:(NSArray *)photos
{
    if (_photos != photos){
        _photos = photos;
        if (self.tableView.window) [self.tableView reloadData];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//#warning Incomplete method implementation.
    // Return the number of rows in the section.
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
    NSRange start = [[photo objectForKey:FLICKR_PLACE_NAME] rangeOfString:@","];
    if (start.location != NSNotFound)
    {
        cell.textLabel.text = [[photo objectForKey:FLICKR_PLACE_NAME] substringToIndex:start.location];
        cell.detailTextLabel.text = [[photo objectForKey:FLICKR_PLACE_NAME] substringFromIndex:start.location + start.length];
    }

    return cell;
    
}

#pragma mark - Table view delegate
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{        
    //NSLog(@"prepare for segue %@", [sender stringValue]);
    if ([sender isKindOfClass:[UIBarButtonItem class]]){      
        [segue.destinationViewController setDelegate:self];
        [segue.destinationViewController setAnnotations:[self mapAnnotations]];
        
    }else{
        self.place = [self.photos objectAtIndex:[[self.tableView indexPathForSelectedRow] row]];
        [segue.destinationViewController setPlaceForPhotos: self.place];
    
    }
}


@end
