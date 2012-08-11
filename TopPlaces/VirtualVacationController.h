//
//  VirtualVacation.h
//  TopPlaces
//
//  Created by timnit gebru on 8/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VirtualVacationController : UITableViewController <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *vacationUserInput;
@property (nonatomic, strong) NSArray *virtualVacations;  // Names of our virtual vacations

- (void)readVirtualVacations;

@end
