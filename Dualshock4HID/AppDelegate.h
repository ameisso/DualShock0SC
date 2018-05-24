//
//  AppDelegate.h
//  Dualshock4HID
//
//  Created by Antoine on 13/11/16.
//  Copyright © 2016 Antoine. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <DDHidLib/DDHidLib.h>
#import <VVOSC/VVOSC.h>

#define BUTTON_1 7
#define BUTTON_2 8
#define BUTTON_3 9
#define BUTTON_4 10
#define BUTTON_5 11

#define WHEEL 16
#define DIAL 17

#define SQUARE_BUTTON 0
#define CROSS_BUTTON 1
#define CIRCLE_BUTTON 2
#define TRIANGLE_BUTTON 3

#define L1_BUTTON 4
#define R1_BUTTON 5
#define L2_BUTTON 6
#define R2_BUTTON 7

#define SHARE_BUTTON 8
#define OPTION_BUTTON 9

#define LEFT_HAT_BUTTON 10
#define RIGHT_HAT_BUTTON 11

#define PS_BUTTON 12
#define PAD_BUTTON 13

#define L2_JOYSTICK 2
#define R2_JOYSTICK 3


#define RIGHT_JOYSTICK_X 0
#define RIGHT_JOYSTICK_Y 1


@interface AppDelegate : NSObject <NSApplicationDelegate>
{
    NSArray *devices;
    OSCManager *oscManager;
    OSCOutPort *outPort;
    
    DDHidDevice *hidDevice;
    NSArray *hidElements;
    
    IBOutlet NSPopUpButton *oscTargetPopUpButton;
    
    IBOutlet NSTextField *button1TextField;
    IBOutlet NSTextField *button2TextField;
    IBOutlet NSTextField *button3TextField;
    IBOutlet NSTextField *button4TextField;
    IBOutlet NSTextField *button5TextField;
    IBOutlet NSTextField *wheelTextField;
    IBOutlet NSTextField *dialTextField;
    IBOutlet NSTextField *wheelSensivityTextField;
    
    IBOutlet NSImageView *button1ImageView;
    IBOutlet NSImageView *button2ImageView;
    IBOutlet NSImageView *button3ImageView;
    IBOutlet NSImageView *button4ImageView;
    
    IBOutlet NSImageView *button5ImageView;
    IBOutlet NSImageView *wheelImageView;
    IBOutlet NSImageView *dialImageView;
    
    IBOutlet NSButton *lockButton;
    
    BOOL isButton1Pressed;
    BOOL isButton2Pressed;
    BOOL isButton3Pressed;
    BOOL isButton4Pressed;
    BOOL isButton5Pressed;
    IBOutlet NSImageView *outPortImageView;
    
    long dialValue;
    long wheelValue;
    NSTimer *deviceUpdateTimer;
    float throttleSensivity;
   
}

@property  BOOL sendWheelWithTimer;
@end

