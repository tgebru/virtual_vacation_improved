//
//  OptionsViewController.m
//  TopPlaces
//
//  Created by timnit gebru on 8/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "OptionsViewController.h"
#import "PlacesViewController.h"
#import "TagsViewController.h"

@interface OptionsViewController()
@property (nonatomic, strong) NSString *vacationDatabaseName;
@end


@implementation OptionsViewController
@synthesize vacationDatabaseName = _vacationDatabaseName;

-(void) updateVacationDatabaseName: (NSString *) vacationDatabaseName
{
    self.vacationDatabaseName = vacationDatabaseName;
    NSLog(@"%s: vacation db name: %@", __FUNCTION__, vacationDatabaseName);
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setTitle:self.vacationDatabaseName];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
//#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    return cell;
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.destinationViewController respondsToSelector:@selector(setVacationName:)] ){
      //  NSLog(@"responds to selector"); 
        [segue.destinationViewController performSelector:@selector(setVacationName:) withObject:self.vacationDatabaseName];
        }    
}

@end
