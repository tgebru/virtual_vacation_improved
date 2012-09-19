//
//  ChooseOptionsViewController.h
//  TopPlaces
//
//  Created by timnit gebru on 9/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ChooseOptionsViewController;

@protocol ChooseOptionsViewControllerDelegate <NSObject>
- (void)chooseOptionsViewController:(ChooseOptionsViewController *)sender
               choseOption:(NSString *)option;
@end

@interface ChooseOptionsViewController : UITableViewController

@property (nonatomic, copy) NSArray *listOfOptions;
@property (nonatomic, weak) id <ChooseOptionsViewControllerDelegate> delegate;

@end


