//
//  MapViewController.m
//  TopPlaces
//
//  Created by timnit gebru on 8/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MapViewController.h"
#import "FlickerRecentPhotosFromPlaceViewController.h"
#import "Cache.h"

@interface MapViewController() <MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) NSDictionary *place;
@property (strong, nonatomic) NSDictionary *photo;
@property (strong, nonatomic) NSDictionary *findIndexInAnnotationsForPhotoTitle;
@property (nonatomic, strong) Cache *flickrPhotoCache;
@property (nonatomic, strong) id<MKAnnotation> currentAnnotation;

@end

@implementation  MapViewController
@synthesize mapView = _mapView;

//@synthesize mapView = _mapView;
@synthesize annotations = _annotations;
@synthesize delegate    = _delegate;
@synthesize place       = _place;
@synthesize photo       = _photo;
@synthesize findIndexInAnnotationsForPhotoTitle = _findIndexInAnnotationsForPhotoTitle;
@synthesize flickrPhotoCache = _flickrPhotoCache;
@synthesize currentAnnotation= _currentAnnotation;


#pragma mark - Synchronize Model and View

- (void) showSpinner
{
    //Show a spinner to indicate that photos are getting downloaded
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [spinner startAnimating];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
}

- (void) updateMapView
{
    if (self.mapView.annotations) [self.mapView removeAnnotations:self.mapView.annotations];
    if (self.annotations)[self.mapView addAnnotations:self.annotations];
    self.navigationController.toolbarHidden=YES; 
}

- (void)setMapView: (MKMapView *)mapView
{
    _mapView = mapView;
    [self updateMapView];
}

- (void) setAnnotations:(NSArray *)annotations
{
    _annotations = annotations;
    [self updateMapView];
}

#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    MKAnnotationView *aView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"MapVC"];
    if (!aView) {
        aView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"MapVC"];
        aView.leftCalloutAccessoryView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        aView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    }    
    aView.annotation = annotation;
    [(UIImageView *)aView.leftCalloutAccessoryView setImage:nil];
    aView.canShowCallout = YES;
    return aView;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)aView
{
    UIImage *image = [self.delegate mapViewController:self imageForAnnotation:aView.annotation];
    [(UIImageView *)aView.leftCalloutAccessoryView setImage:image];
    NSLog(@"We have selected an annotation view");

}

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    self.currentAnnotation = view.annotation;
    NSLog (@"callout accessory tapped for annoation %@", [view.annotation title]);
    if ([self.delegate isKindOfClass:[FlickerPhotosViewController class]]){
        self.place=[self.delegate mapViewcontroller:self getDataForAnnotation:view.annotation];
        [self performSegueWithIdentifier:@"toListOfPhotosFromMap" sender:self.delegate];  
    }else{
        //self.photo=[self.delegate mapViewcontroller:self getDataForAnnotation:view.annotation];
        [self performSegueWithIdentifier:@"toPhotoFromMap" sender:self.delegate];  
    }
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[FlickerRecentPhotosFromPlaceViewController class]]){
        [segue.destinationViewController setPlaceForPhotos: self.place];    
    }else{
        UIImage *photoImage = [self.delegate mapViewController:self bigPhotoForAnnotation:self.currentAnnotation];
        [segue.destinationViewController setImage:photoImage];
    }
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.mapView.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.mapView.delegate = self;
}
- (void)viewDidUnload
{
    [self setMapView:nil];
    [self setMapView:nil];
    [super viewDidUnload];
}


#pragma mark - Autorotation 

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

@end
