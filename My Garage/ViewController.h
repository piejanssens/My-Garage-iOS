//
//  ViewController.h
//  My Garage
//
//  Created by Pieter Janssens on 12/12/13.
//  Copyright (c) 2013 Pieter Janssens. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLE.h" 

@interface ViewController : UIViewController <BLEDelegate>
@property (strong, nonatomic) BLE *ble;

@end
