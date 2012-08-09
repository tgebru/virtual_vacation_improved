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
@synthesize annotations = _annotations;
@synthesize delegate    = _delegate;
@synthesize place       = _place;
@synthesize photo       = _photo;
@synthesize findIndexInAnnotationsForPhotoTitle = _findIndexInAnnotationsForPhotoTitle;
@synthesize flickrPhotoCache = _flickrPhotoCache;
@synthesize currentAnnotation= _currentAnnotation;


#define MINIMUM_ZOOM_ARC 0.014 //approximately 1 miles (1 degree of arc ~= 69 miles)
#define ANNOTATION_REGION_PAD_FACTOR 1.15
#define MAX_DEGREES_ARC 360


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
    
    //Adjust map view bounds to show all annotations
    int count = [self.mapView.annotations count];
    MKMapPoint points[count]; //C array of MKMapPoint struct
    for( int i=0; i<count; i++ ) //load points C array by converting coordinates to points
    {
        CLLocationCoordinate2D coordinate = [(id <MKAnnotation>)[self.annotations objectAtIndex:i] coordinate];
        points[i] = MKMapPointForCoordinate(coordinate);
    }
    //create MKMapRect from array of MKMapPoint
    MKMapRect mapRect = [[MKPolygon polygonWithPoints:points count:count] boundingMapRect];

    //convert MKCoordinateRegion from MKMapRect
    MKCoordinateRegion region = MKCoordinateRegionForMapRect(mapRect);
 
    //add padding so pins aren't scrunched on the edges
    region.span.latitudeDelta  *= ANNOTATION_REGION_PAD_FACTOR;
    region.span.longitudeDelta *= ANNOTATION_REGION_PAD_FACTOR;
    
    //but padding can't be bigger than the world
    if( region.span.latitudeDelta > MAX_DEGREES_ARC ) { region.span.latitudeDelta  = MAX_DEGREES_ARC; }
    if( region.span.longitudeDelta > MAX_DEGREES_ARC ){ region.span.longitudeDelta = MAX_DEGREES_ARC; }


    //and don't zoom in stupid-close on small samples
    if( region.span.latitudeDelta  < MINIMUM_ZOOM_ARC ) { region.span.latitudeDelta  = MINIMUM_ZOOM_ARC; }
    if( region.span.longitudeDelta < MINIMUM_ZOOM_ARC ) { region.span.longitudeDelta = MINIMUM_ZOOM_ARC; }
 
    //and if there is a sample of 1 we want the max zoom-in instead of max zoom-out
   
    if( count == 1 )
    { 
        region.span.latitudeDelta = MINIMUM_ZOOM_ARC;
        region.span.longitudeDelta = MINIMUM_ZOOM_ARC;
    }
    [self.mapView setRegion:region animated:YES];

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
    NSLog (@"Title, %@", aView.annotation.title);
     NSLog (@"Subtitile, %@", aView.annotation.subtitle);
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
        [self.delegate mapViewController:self bigPhotoForAnnotation:self.currentAnnotation];
        NSLog(@"returned from fetching image");
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[FlickerRecentPhotosFromPlaceViewController class]]){
        [segue.destinationViewController setPlaceForPhotos: self.place];    
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
