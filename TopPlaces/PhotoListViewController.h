//
//  PhotoListViewController.h
//  TopPlaces
//
//  Created by timnit gebru on 8/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataTableViewController.h"

@interface PhotoListViewController : CoreDataTableViewController
{
    NSString * listParent;
    NSString * vacationName;
}
@property (nonatomic, strong) NSString * listParent;
@property (nonatomic, strong) NSString * vacationName;

@end

