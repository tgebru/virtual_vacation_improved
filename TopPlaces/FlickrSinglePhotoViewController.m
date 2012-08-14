//
//  FlickrSinglePhotoViewController.m
//  TopPlaces
//
//  Created by timnit gebru on 7/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FlickrSinglePhotoViewController.h"
#import "VacationHelper.h"
//#import "Photo+Create.h"
#import <CoreData/CoreData.h>
#import "Photo+Create.h"
#import "Photo.h"

@interface FlickrSinglePhotoViewController() <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) NSDictionary *photoDictionary;
//@property (nonatomic, strong) UIImage *image;

//-(void) documentIsReady:(UIManagedDocument *)doc;

@end

@implementation FlickrSinglePhotoViewController
//@synthesize visitButton;
@synthesize imageView ;
@synthesize scrollView;
@synthesize photoDictionary = _photoDictionary;
//@synthesize image =_image;

- (void) showSpinner
{
    //Show a spinner to indicate that photos are getting downloaded
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [spinner startAnimating];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
}

-(void) documentIsReady:(UIManagedDocument *)doc {
    
    if (doc.documentState == UIDocumentStateNormal){
        
        dispatch_queue_t fetchQ = dispatch_queue_create("Flickr fetcher", NULL);
        dispatch_async(fetchQ, ^{
            //Save photo to database            
            [doc.managedObjectContext performBlock:^{ // perform in the NSMOC's safe thread (main thread)
                [Photo photoWithFlickrInfo:self.photoDictionary inManagedObjectContext:doc.managedObjectContext];
                
                //Save the document
                [doc saveToURL:doc.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success) {
                    if (!success) NSLog(@"failed to save document %@ in Visit unVisit", doc.localizedName);
                    else {
                        NSLog(@"%s: we saved okay", __FUNCTION__);
                    }
                }];
            }];            
            dispatch_release(fetchQ);
                        
        });
    }
}

- (IBAction)toggleVisit:(id)sender {
    //Toggle title of button
    if ([sender isKindOfClass:[UIButton class]]){
        NSLog (@"it is a UIButton");
        UIButton *visitButton = (UIButton *)sender;
        if ([visitButton.titleLabel.text compare:@"Visit"] == NSOrderedSame){
            
            //save to my vacation database: the database name is hard coded
            [VacationHelper openVacation:@"My Vacation"
                              usingBlock:^ (UIManagedDocument *doc){
                                  [self documentIsReady:doc];
                              }];

            
            [visitButton setTitle:@"Unvisit" forState:UIControlStateNormal];
        }else {
            //TODO: delete from db
            [visitButton setTitle:@"Visit" forState:UIControlStateNormal];
            
            //Delete from Database 
            
        }
    }

    }


//- (void)setImage:(UIImage *)image
- (void)setImage:(UIImage *)image forPhotoDictionary:(NSDictionary *)photoDictionary
{
    NSLog(@"Flickr: %s", __FUNCTION__);
    [self showSpinner];  
    [self.imageView setImage:image];
    [self.imageView setNeedsDisplay];
    self.photoDictionary = photoDictionary;
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
    //[self setVisitButton:nil];
    [super viewDidUnload];
}

@end
