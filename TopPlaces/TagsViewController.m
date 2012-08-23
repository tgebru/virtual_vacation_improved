//
//  TagsViewController.m
//  TopPlaces
//
//  Created by timnit gebru on 8/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TagsViewController.h"
#import "FlickrFetcher.h"
#import "VacationHelper.h"
#import "Tag.h"
#import "PhotoListViewController.h"

@interface TagsViewController() 
@property (nonatomic, strong) UIManagedDocument *photoDatabase;
@property (nonatomic, strong) NSString *vacationName;
@end


@implementation TagsViewController

@synthesize vacationName = _vacationName;
@synthesize photoDatabase=_photoDatabase;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

- (void)setupFetchedResultsController // attaches an NSFetchRequest to this UITableViewController
{
    NSLog(@"TagsList: %s", __FUNCTION__);

    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName: @"Tag"];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
    // no predicate because we want ALL the Photographers
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.photoDatabase.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
}

-(void) documentIsReady:(UIManagedDocument *)doc {
    NSLog(@"TagsList: %s", __FUNCTION__);

    self.photoDatabase = doc;
    [self setupFetchedResultsController];
    
    //[self fetchFlickrDataIntoDocument:self.photoDatabase];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"TagsList: %s", __FUNCTION__);

    [super viewWillAppear:animated];
    [self setTitle:self.vacationName];
    [VacationHelper openVacation:self.vacationName
                      usingBlock:^ (UIManagedDocument *doc){
                          [self documentIsReady:doc];
                      }];
}  

- (void)viewDidUnload
{
    NSLog(@"TagsList: %s", __FUNCTION__);

    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"TagsList: %s", __FUNCTION__);

    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // ask NSFetchedResultsController for the NSMO at the row in question
    Tag *tag = [self.fetchedResultsController objectAtIndexPath:indexPath];
    // Then configure the cell using it ...
    cell.textLabel.text = tag.title;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d tags", [tag.photos count]];
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{

    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    Tag *tag = [self.fetchedResultsController objectAtIndexPath:indexPath];
    ////    if ([segue.destinationViewController respondsToSelector:@selector(setPhotographer:)]) {
    ////        [segue.destinationViewController performSelector:@selector(setPhoto:) withObject:photographer];
    ////    }
    //  
    //    // updateTag/titleParent
    //objectAtIndex:[[self.tableView indexPathForSelectedRow] row]];
    [segue.destinationViewController setCameFromTags:YES];
    [segue.destinationViewController setVacationName:self.vacationName];
    [segue.destinationViewController setListParent:tag.title];
    //    
    //    
    NSLog(@"TagsList: Inside Prepare for Segue Places View controller");
}
@end
