//
//  FlickrSinglePhotoViewController.h
//  TopPlaces
//
//  Created by timnit gebru on 7/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FlickrSinglePhotoViewController : UIViewController
//@property (weak, nonatomic) IBOutlet UIButton *visitButton;
//@property (nonatomic, strong) UIImage *image;
- (void)setImage:(UIImage *)image forPhotoDictionary:(NSDictionary *)photoDictionary;
- (IBAction)toggleVisit:(id)sender;

@end
