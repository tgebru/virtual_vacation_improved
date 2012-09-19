//
//  PhotoListViewController.m
//  TopPlaces
//
//  Created by timnit gebru on 8/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PhotoListViewController.h"
#import "VacationHelper.h"
#import "Photo.h"
#import "Place.h"
#import "Cache.h"
#import "FlickrFetcher.h"
#import "FlickrSinglePhotoViewController.h"

@interface PhotoListViewController() 
@property (nonatomic, strong)UIManagedDocument *photoDatabase;
@property (nonatomic, strong) Cache *flickrPhotoCache;

@end


@implementation PhotoListViewController

@synthesize listParent = _listParent;
@synthesize vacationName=_vacationName;
@synthesize photoDatabase = _photoDatabase;
@synthesize flickrPhotoCache = _flickrPhotoCache;
@synthesize cameFromTags  = _cameFromTags;

#pragma mark - Table view data source

/*
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}
*/
- (void)setVacationName:(NSString *)vacationName
{
    _vacationName = vacationName;
    [self.view setNeedsDisplay];
}
#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.flickrPhotoCache = [[Cache alloc]init];
    [self.flickrPhotoCache getCache];
}

- (void)setupFetchedResultsController // attaches an NSFetchRequest to this UITableViewController
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName: @"Photo"];
    
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
    // predicate to get all photos taken at a given place
    if (self.cameFromTags){
        request.predicate = [NSPredicate predicateWithFormat:@"any tagName.title contains %@", self.listParent];
    }else {        
        request.predicate = [NSPredicate predicateWithFormat:@"takenAt.name = %@", self.listParent];
    }
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.photoDatabase.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
}

-(void)documentIsReady:(UIManagedDocument *)doc 
    {
    
    self.photoDatabase = doc;
    [self setupFetchedResultsController];
    
    //[self fetchFlickrDataIntoDocument:self.photoDatabase];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setTitle:self.listParent];
    [VacationHelper openVacation:self.vacationName
                      usingBlock:^ (UIManagedDocument *doc){
                          [self documentIsReady:doc];
                      }];
    
    NSLog(@"%s", __FUNCTION__);
}  

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // ask NSFetchedResultsController for the NSMO at the row in question
    Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = photo.title;

//    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d photos", [place.photos count]];
   return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    Photo *photo1 = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    NSArray *keys = [NSArray arrayWithObjects:FLICKR_PLACE_ID, FLICKR_PHOTO_ID, nil];
    NSArray *objects = [NSArray arrayWithObjects:photo1.takenAt.unique, photo1.unique, nil];
    NSDictionary *photo = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
  
    //NSLog(@"prepare for segue %@", [sender stringValue]);
    NSLog(@"inside prepareForSegue");
        
        //Fork a thread to download photos
        dispatch_queue_t downloadQueue = dispatch_queue_create("flickr downloader", NULL);
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
                UIImage *photoImage= [UIImage imageWithData:imageData];
                //NSLog(@"Downloaded Image height: %f", [self.photoImage size].height);
                
                //Save photo to cache
                [self.flickrPhotoCache writeImageToCache:imageData forPhoto:photo fromUrl:photoUrl]; //update photo cache
                NSLog(@"done caching");
                
                //save to NSUserDefaults  
                //[self saveToNSDefaults:photo];
                
               // self.navigationItem.rightBarButtonItem = nil;
                //[segue.destinationViewController setVisitedPic:YES];
                [segue.destinationViewController setVisitedPic: [NSNumber numberWithBool:YES]];
                [segue.destinationViewController setVacationName:self.vacationName];
                [segue.destinationViewController setImage:photoImage forPhotoDictionary:photo];
                
            });
        });
        
        dispatch_release(downloadQueue);
}

@end
