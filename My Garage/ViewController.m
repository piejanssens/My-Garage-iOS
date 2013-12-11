//
//  ViewController.m
//  My Garage
//
//  Created by Pieter Janssens on 10/12/13.
//  Copyright (c) 2013 Pieter Janssens. All rights reserved.
//

#import "ViewController.h"
#import "MRProgress.h"

//To add some form of authentication:
//Change the BLE_PINCODE bytes to any random combination of valid unsigned bytes (0-255)
//Use Google e.g. "76 to hex" will result in "0x4C"
//Define the same 4 pincode bytes in the Arduino Garage Control sketch

const UInt8 BLE_PINCODE[4] = {0x01, 0x01, 0x01, 0x01};
@interface ViewController ()

@end

@implementation ViewController
@synthesize ble;

- (void)viewDidLoad
{
    [super viewDidLoad];

    ble = [[BLE alloc] init];
    [ble controlSetup];
    ble.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
}

- (void)appDidBecomeActive:(NSNotification *)notification {
    if ([MRProgressOverlayView allOverlaysForView:self.view].count == 0) {
        [MRProgressOverlayView showOverlayAddedTo:self.view animated:YES];
        [MRProgressOverlayView overlayForView:self.view].titleLabelText = @"Verbinden ...";
    }
    NSLog(@"did become active notification");
    [self reconnect];
}

- (void)reconnect {
    if ([ble CM].state == CBCentralManagerStatePoweredOn) {
        [ble scanForPeripheral];
    }
    else {
        [NSTimer scheduledTimerWithTimeInterval:0.1
                                         target:self
                                       selector:@selector(reconnect)
                                       userInfo:nil
                                        repeats:NO];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - BLE delegate


- (void)bleDidDisconnect
{
    //
}

// When RSSI is changed, this will be called
-(void) bleDidUpdateRSSI:(NSNumber *) rssi
{
    //
}

- (void)appWillResignActive:(NSNotification *)notification {
    NSLog(@"will resign active notification");
    [MRProgressOverlayView dismissOverlayForView:self.view animated:YES];
    if ([ble activePeripheral]) {
        [[ble CM] cancelPeripheralConnection:[ble activePeripheral]];
    }
    else {
        [[ble CM] stopScan];
    }
}

- (void) quitApplication {
    [MRProgressOverlayView dismissOverlayForView:self.view animated:YES];
    [[ble CM] cancelPeripheralConnection:[ble activePeripheral]];
    exit(0);
}

// When disconnected, this will be called
-(void) bleDidConnect
{
    [MRProgressOverlayView dismissOverlayForView:self.view animated:YES];
    
    UInt8 buf[5] = {
        0x01,
        BLE_PINCODE[0],
        BLE_PINCODE[1],
        BLE_PINCODE[2],
        BLE_PINCODE[3],
    };

    [ble write: [[NSData alloc] initWithBytes:buf length:5]];
    
    [self performSelector:@selector(quitApplication) withObject:nil afterDelay:0.1];
}

// When data is comming, this will be called
-(void) bleDidReceiveData:(unsigned char *)data length:(int)length
{
    // parse data, all commands are in 3-byte
}

@end
