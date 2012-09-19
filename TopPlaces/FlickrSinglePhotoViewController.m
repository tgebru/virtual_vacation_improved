//
//  FlickrSinglePhotoViewController.m
//  TopPlaces
//
//  Created by timnit gebru on 7/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FlickrSinglePhotoViewController.h"
#import "VacationHelper.h"
#import <CoreData/CoreData.h>
#import "Photo+Create.h"
#import "Photo+Delete.h"
#import "Photo.h"
#import "ChooseOptionsViewController.h"

@interface FlickrSinglePhotoViewController() <UIScrollViewDelegate, ChooseOptionsViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) NSDictionary *photoDictionary;
//@property (nonatomic, strong) UIImage *image;

-(void) documentIsReady:(UIManagedDocument *)doc :(NSString *)actionToDo;

@end

@implementation FlickrSinglePhotoViewController
@synthesize visitButton = _visitButton;
@synthesize imageView ;
@synthesize scrollView;
@synthesize photoDictionary = _photoDictionary;
@synthesize visitedPic = _visitedPic;
//@synthesize image =_image;

- (void) showSpinner
{
    //Show a spinner to indicate that photos are getting downloaded
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [spinner startAnimating];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
}

-(void) documentIsReady:(UIManagedDocument *)doc :(NSString *)actionToDo {
    
    if (doc.documentState == UIDocumentStateNormal){
        
        dispatch_queue_t fetchQ = dispatch_queue_create("Flickr fetcher", NULL);
        dispatch_async(fetchQ, ^{
            //Save photo to database            
            [doc.managedObjectContext performBlock:^{ // perform in the NSMOC's safe thread (main thread)
                
                if([actionToDo compare:@"create"] == NSOrderedSame) {
                [Photo photoWithFlickrInfo:self.photoDictionary inManagedObjectContext:doc.managedObjectContext];
                } else {
                [Photo deleteWithFlickrInfo:self.photoDictionary inManagedObjectContext:doc.managedObjectContext];
                }
                
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

/*
- (IBAction)toggleVisit:(id)sender {
    //Toggle title of button
    if ([sender isKindOfClass:[UIButton class]]){
        NSLog (@"it is a UIButton");
        UIButton *visitButton = (UIButton *)sender;
        
        NSString *vacationName = @"Another Vacation";//@"My Vacation";
        [self visitOrUnvisitVacation:vacationName];
        if ([visitButton.titleLabel.text compare:@"Visit"] == NSOrderedSame){
            
            //save to my vacation database: the database name is hard coded
            //To do ask user to enter new vacation or save to existing vacation
            [VacationHelper openVacation: vacationName
                              usingBlock:^ (UIManagedDocument *doc){
                                  [self documentIsReady:doc :@"create"];
                              }];

            
            [visitButton setTitle:@"Unvisit" forState:UIControlStateNormal];
        }else {
            //delete from db
            [VacationHelper openVacation:vacationName
                              usingBlock:^ (UIManagedDocument *doc){
                                  [self documentIsReady:doc :@"delete"];
                              }];
            
            [visitButton setTitle:@"Visit" forState:UIControlStateNormal];
                        
        }
    }

}
*/
- (NSArray*)readVirtualVacationsFromPlist
{
    NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *vacationPath = [documentsDirectory stringByAppendingPathComponent:@"vacations.plist"];
    if (vacationPath){
       return [[[NSDictionary alloc] initWithContentsOfFile:vacationPath] allKeys]; 
    }
    return nil;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //Toggle title of button
    if ([sender isKindOfClass:[UIButton class]]){
        NSLog (@"it is a UIButton");
        UIButton *visitButton = (UIButton *)sender;
        
        if ([visitButton.titleLabel.text compare:@"Visit"] == NSOrderedSame){
            self.visitedPic = [NSNumber numberWithBool:NO];
                [visitButton setTitle:@"Unvisit" forState:UIControlStateNormal];
        }else {
            self.visitedPic = [NSNumber numberWithBool:YES];
                       [visitButton setTitle:@"Visit" forState:UIControlStateNormal];
            
        }
        ChooseOptionsViewController *options = (ChooseOptionsViewController *)segue.destinationViewController;
        options.listOfOptions = [self readVirtualVacationsFromPlist];
        options.delegate = self;
    }
 
}

- (void)chooseOptionsViewController:(ChooseOptionsViewController *)sender
                        choseOption:(NSString *)option
{
    NSString *vacationName = option;
    if (self.visitedPic.boolValue){
        //save to my vacation database: the database name is hard coded
        //To do ask user to enter new vacation or save to existing vacation
        [VacationHelper openVacation: vacationName
                          usingBlock:^ (UIManagedDocument *doc){
                              [self documentIsReady:doc :@"create"];
                          }];
    }else{
        //delete from db
        [VacationHelper openVacation:vacationName
                          usingBlock:^ (UIManagedDocument *doc){
                              [self documentIsReady:doc :@"delete"];
                          }];
        
    }
    [self dismissModalViewControllerAnimated:YES];
}

- (void)setImage:(UIImage *)image forPhotoDictionary:(NSDictionary *)photoDictionary
{
    NSLog(@"Flickr: %s", __FUNCTION__);
    [self showSpinner];  
    [self.imageView setImage:image];
    [self.imageView setNeedsDisplay];
    self.photoDictionary = photoDictionary;
    if(self.visitedPic == [NSNumber numberWithBool:YES]) {
       [self.visitButton setTitle:@"Unvisit" forState:UIControlStateNormal];       
    }
    [self.scrollView setNeedsDisplay];
    self.navigationItem.rightBarButtonItem = nil;
}

- (void)viewDidLoad
{
    NSLog(@"Flickr: %s", __FUNCTION__);
    [super viewDidLoad];
    if (!self.imageView.image) {[self showSpinner];}

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
    
 /*   
    if(self.visitedPic == [NSNumber numberWithBool:YES]) {
        [[self.visitButton titleLabel] setText:@"Unvisit"];
    }
 */
    //self.imageView.frame = CGRectMake(0, 0, self.imageView.image.size.width, self.imageView.image.size.height);
    self.scrollView.delegate = self;
    self.scrollView.contentSize = self.imageView.image.size;

    NSLog(@"%s, parent: %@", __FUNCTION__, [self.parentViewController title]);
    NSLog(@"parent: %@", [self.parentViewController nibName]);
    
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
