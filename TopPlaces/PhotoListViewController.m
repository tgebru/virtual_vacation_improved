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

@interface PhotoListViewController() 
@property (nonatomic, strong)UIManagedDocument *photoDatabase;

@end


@implementation PhotoListViewController

@synthesize listParent = _listParent;
@synthesize vacationName=_vacationName;
@synthesize photoDatabase = _photoDatabase;

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}


- (void)setupFetchedResultsController // attaches an NSFetchRequest to this UITableViewController
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName: @"Photo"];
    
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
    // predicate to get all photos taken at a given place
    request.predicate = [NSPredicate predicateWithFormat:@"takenAt.name = %@", self.listParent];
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


/*
 - (void)fetchFlickrDataIntoDocument:(UIManagedDocument *)document
 {
 dispatch_queue_t fetchQ = dispatch_queue_create("Flickr fetcher", NULL);
 dispatch_async(fetchQ, ^{
 NSArray *photos = [FlickrFetcher recentGeoreferencedPhotos];
 [document.managedObjectContext performBlock:^{ // perform in the NSMOC's safe thread (main thread)
 for (NSDictionary *flickrInfo in photos) {
 [Photo photoWithFlickrInfo:flickrInfo inManagedObjectContext:document.managedObjectContext];
 // table will automatically update due to NSFetchedResultsController's observing of the NSMOC
 }
 [document saveToURL:document.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:NULL];
 }];
 });
 dispatch_release(fetchQ);
 }
 
 - (void)useDocument
 {
 if (![[NSFileManager defaultManager] fileExistsAtPath:[self.photoDatabase.fileURL path]]) {
 // does not exist on disk, so create it
 [self.photoDatabase saveToURL:self.photoDatabase.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
 [self setupFetchedResultsController];
 [self fetchFlickrDataIntoDocument:self.photoDatabase];
 
 }];
 } else if (self.photoDatabase.documentState == UIDocumentStateClosed) {
 // exists on disk, but we need to open it
 [self.photoDatabase openWithCompletionHandler:^(BOOL success) {
 [self setupFetchedResultsController];
 }];
 } else if (self.photoDatabase.documentState == UIDocumentStateNormal) {
 // already open and ready to use
 [self setupFetchedResultsController];
 }
 }
 
 - (void)setPhotoDatabase:(UIManagedDocument *)photoDatabase
 {
 if (_photoDatabase != photoDatabase) {
 _photoDatabase = photoDatabase;
 [self useDocument];
 }
 }
 
 - (void)viewWillAppear:(BOOL)animated
 {
 [super viewWillAppear:animated];
 
 if (!self.photoDatabase) {  // for demo purposes, we'll create a default database if none is set
 NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
 url = [url URLByAppendingPathComponent:@"Default Photo Database"];
 // url is now "<Documents Directory>/Default Photo Database"
 self.photoDatabase = [[UIManagedDocument alloc] initWithFileURL:url]; // setter will create this for us on disk
 }
 }
 */
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


//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//{
//    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
//    Photo *photographer = [self.fetchedResultsController objectAtIndexPath:indexPath];
//    if ([segue.destinationViewController respondsToSelector:@selector(setPhotographer:)]) {
//        [segue.destinationViewController performSelector:@selector(setPhoto:) withObject:photographer];
//    }
//    
//    
//    
//    
//}
@end
