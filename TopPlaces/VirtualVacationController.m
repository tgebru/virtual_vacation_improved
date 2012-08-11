//
//  VirtualVacation.m
//  TopPlaces
//
//  Created by timnit gebru on 8/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VirtualVacationController.h"
#import "OptionsViewController.h"

@implementation VirtualVacationController
@synthesize vacationUserInput = _vacationUserInput;
@synthesize  virtualVacations =_virtualVacations;  // Names of our virtual vacations

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.vacationUserInput.delegate = self;
}

- (void)viewDidUnload
{
    [self setVacationUserInput:nil];
    [super viewDidUnload];
}

#pragma mark - UITextField delegate

- (BOOL) textFieldShouldReturn:(UITextField *) textField 
{
    [self.vacationUserInput resignFirstResponder];
    return NO;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range 
 replacementText:(NSString *)text
{
    // Any new character added is passed in as the "text" parameter
    if ([text isEqualToString:@"\n"]) {
        // Be sure to test for equality using the "isEqualToString" message
        [textView resignFirstResponder];
        NSLog(@"%@", self.vacationUserInput.text);

        // Return FALSE so that the final '\n' character doesn't get added
        return FALSE;
    }
    // For any other character return TRUE so that the text gets added to the view
    return TRUE;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    NSLog(@"%@", self.vacationUserInput.text);
//    [self.virtualVacations addObject:self.vacationUserInput.text];
}

/*
- (IBAction)textFieldDoneEditing:(id)sender {
    //hide the keypad when done is pressed
    [sender resignFirstResponder];
}
 */

- (IBAction)createNewVacation:(id)sender 
{
    if (self.vacationUserInput.text && [self.vacationUserInput.text compare:@"Enter Vacation Name and Click Add"] ){
        NSLog(@"%s: %@", __FUNCTION__, self.vacationUserInput.text);
        
        NSString *input = self.vacationUserInput.text;
        
        [self.vacationUserInput resignFirstResponder];

        //insert into plist
        NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        NSString *vacationPath = [documentsDirectory stringByAppendingPathComponent:@"vacations.plist"];
        if (vacationPath){
            
            NSDictionary *temp = [[NSDictionary alloc] initWithContentsOfFile:vacationPath];
            
            if ([temp count] == 0) {
                NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
                
                [dict setObject:[self.vacationUserInput.text 
                                 stringByAppendingString:@" database"] forKey:input];
                [dict writeToFile:vacationPath atomically:YES];

                NSLog(@"empty file");
            }
            else {
                
                NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
                
                [dict setObject:@"" forKey:input];
                
                for (NSString *key in temp) {
                    id value = [temp objectForKey:key];
                    [dict setObject:value forKey:key];
                }
                
                [dict writeToFile:vacationPath atomically:YES];
                NSLog(@"not empty file");
            }
        }
        
        [self readVirtualVacations];
    }
}

- (void)readVirtualVacations
{
    NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *vacationPath = [documentsDirectory stringByAppendingPathComponent:@"vacations.plist"];
    if (vacationPath){
        self.virtualVacations = [[[NSDictionary alloc] initWithContentsOfFile:vacationPath] allKeys];            
    } else {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
        [dict writeToFile:vacationPath atomically:YES];
    }
    
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self readVirtualVacations];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.virtualVacations count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"vacations";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.text = [self.virtualVacations objectAtIndex:[indexPath row]];
    cell.detailTextLabel.text= @"";

    return cell;
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSString *vacationName = [self.virtualVacations objectAtIndex:[[self.tableView indexPathForSelectedRow] row]];
   // NSLog (@"%@", [segue.destinationViewController name]);
    [segue.destinationViewController updateVacationDatabaseName: vacationName];
}

@end
