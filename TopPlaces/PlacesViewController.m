//
//  PlacesViewController.m
//  TopPlaces
//
//  Created by timnit gebru on 8/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PlacesViewController.h"
#import "FlickrFetcher.h"
#import "VacationHelper.h"
#import "Place.h"
#import "PhotoListViewController.h"

@interface PlacesViewController() 
@property (nonatomic, strong) UIManagedDocument *photoDatabase;
@property (nonatomic, strong) NSString *vacationName;

-(void) documentIsReady:(UIManagedDocument *) doc;

@end


@implementation PlacesViewController

@synthesize vacationName;
@synthesize photoDatabase=_photoDatabase;

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setTitle:self.vacationName];
    [VacationHelper openVacation:self.vacationName
                      usingBlock:^ (UIManagedDocument *doc){
                          [self documentIsReady:doc];
                      }];
}  

- (void)viewDidUnload
{
    [super viewDidUnload];
}

-(void)viewDidAppear:(BOOL)animated
{
    if([self.tableView numberOfRowsInSection:0]==0)[self.navigationController popViewControllerAnimated:YES];
}

- (void)setupFetchedResultsController // attaches an NSFetchRequest to this UITableViewController
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName: @"Place"];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
    // no predicate because we want ALL the Photographers
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.photoDatabase.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
}
     
-(void) documentIsReady:(UIManagedDocument *)doc {
    
    self.photoDatabase = doc;
    [self setupFetchedResultsController];
    
   //[self fetchFlickrDataIntoDocument:self.photoDatabase];
    
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
    Place *place = [self.fetchedResultsController objectAtIndexPath:indexPath];
    // Then configure the cell using it ...
    cell.textLabel.text = place.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d photos", [place.photos count]];
    return cell;
}

 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    Place *place = [self.fetchedResultsController objectAtIndexPath:indexPath];
////    if ([segue.destinationViewController respondsToSelector:@selector(setPhotographer:)]) {
////        [segue.destinationViewController performSelector:@selector(setPhoto:) withObject:photographer];
////    }
//  
//    // updateTag/titleParent
   //objectAtIndex:[[self.tableView indexPathForSelectedRow] row]];
    [segue.destinationViewController setVacationName:self.vacationName];
    [segue.destinationViewController setListParent:place.name];
//    
//    
    NSLog(@"Inside Prepare for Segue Places View controller");
}
@end
