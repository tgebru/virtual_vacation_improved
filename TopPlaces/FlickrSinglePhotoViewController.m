//
//  FlickrSinglePhotoViewController.m
//  TopPlaces
//
//  Created by timnit gebru on 7/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FlickrSinglePhotoViewController.h"

@interface FlickrSinglePhotoViewController() <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
//@property (nonatomic, strong) UIImage *image;
@end

@implementation FlickrSinglePhotoViewController
@synthesize imageView ;
@synthesize scrollView;
//@synthesize image =_image;

- (void) showSpinner
{
    //Show a spinner to indicate that photos are getting downloaded
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [spinner startAnimating];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
}

- (void)setImage:(UIImage *)image
{
    NSLog(@"Flickr: %s", __FUNCTION__);
    [self showSpinner];  
    [self.imageView setImage:image];
    [self.imageView setNeedsDisplay];
    [self.scrollView setNeedsDisplay];
    self.navigationItem.rightBarButtonItem = nil;
}

- (void)viewDidLoad
{
    NSLog(@"Flickr: %s", __FUNCTION__);
    [super viewDidLoad];

}

-(void) viewDidAppear:(BOOL)animated
{
    NSLog(@"Flickr: %s", __FUNCTION__);
}

- (void) viewWillAppear:(BOOL)animated
{
    NSLog(@"Flickr: %s", __FUNCTION__);

    //[self.imageView setImage:self.image];

    [super viewWillAppear:animated];


    //self.imageView.frame = CGRectMake(0, 0, self.imageView.image.size.width, self.imageView.image.size.height);
    self.scrollView.delegate = self;
    self.scrollView.contentSize = self.imageView.image.size;
 
    
 /*   
    //Initial zoom to show as much of the photo as possible with no white spaces
    
    //compare width and height of veiwing area with that of image
    float widthRatio = self.view.bounds.size.width / self.imageView.image.size.width;
    float heightRatio =self.view.bounds.size.height / self.imageView.image.size.height;
    
    //Update the zoom scale
    self.scrollView.zoomScale = MAX(widthRatio, heightRatio);
    //CGRect visibleRect = [scrollView convertRect:scrollView.bounds toView:self.imageView];   
    
    //Zooming
    self.scrollView.minimumZoomScale = 0.5;
    self.scrollView.maximumZoomScale = 5;
    self.navigationItem.rightBarButtonItem = nil;
  */

}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (void)viewDidUnload
{
    [self setImageView:nil];
    [self setScrollView:nil];
    [self setScrollView:nil];
    [self setImageView:nil];
    [super viewDidUnload];
}

@end
