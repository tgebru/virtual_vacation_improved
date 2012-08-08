//
//  MapViewController.h
//  TopPlaces
//
//  Created by timnit gebru on 8/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@class MapViewController;

@protocol MapViewControllerDelegate <NSObject>

@required
- (UIImage *)mapViewController: (MapViewController *)sender
            imageForAnnotation:(id <MKAnnotation>)annotation;

- (NSDictionary *)mapViewcontroller: (MapViewController *)sender
            getDataForAnnotation: (id <MKAnnotation>)annotation;
@end

@interface MapViewController : UIViewController
@property (nonatomic, strong)NSArray *annotations; //of id <MKAnnotation>
@property (nonatomic, weak) id <MapViewControllerDelegate> delegate;
@end
