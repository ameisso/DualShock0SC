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
    NSArray *joysticks;
    OSCManager *oscManager;
    OSCOutPort *outPort;
    
    IBOutlet NSPopUpButton *oscTargetPopUpButton;
    IBOutlet NSTextField *triangleTextField;
    IBOutlet NSTextField *circleTextField;
    IBOutlet NSTextField *crossTextField;
    IBOutlet NSTextField *squareTextField;
    
    IBOutlet NSTextField *topTextField;
    IBOutlet NSTextField *rightTextField;
    IBOutlet NSTextField *bottomTextField;
    IBOutlet NSTextField *leftTextField;
    
    IBOutlet NSTextField *L1TextField;
    IBOutlet NSTextField *L2TextField;
    IBOutlet NSTextField *R1TextField;
    IBOutlet NSTextField *R2TextField;
    
    IBOutlet NSTextField *LeftHatButtonTextField;
    IBOutlet NSTextField *RightHatButtonTextField;
    
    IBOutlet NSTextField *L2JoysticktextField;
    IBOutlet NSTextField *R2JoysticktextField;
    
    IBOutlet NSTextField *LHatJoysticktextField;
    IBOutlet NSTextField *RHatJoysticktextField;
    
    IBOutlet NSImageView *outPortImageView;
    
    IBOutlet NSImageView *triangleImageView;
    IBOutlet NSImageView *circleImageView;
    IBOutlet NSImageView *crossImageView;
    IBOutlet NSImageView *squareImageView;
    
    IBOutlet NSImageView *topImageView;
    IBOutlet NSImageView *rightImageView;
    IBOutlet NSImageView *bottomImageView;
    IBOutlet NSImageView *leftImageView;
    
    IBOutlet NSImageView *L1ImageView;
    IBOutlet NSImageView *L2tImageView;
    IBOutlet NSImageView *R1ImageView;
    IBOutlet NSImageView *R2ImageView;
    
    IBOutlet NSImageView *LeftHatButtonImageView;
    IBOutlet NSImageView *RightHatButtonImageView;
    
    IBOutlet NSImageView *L2JoystickImageView;
    IBOutlet NSImageView *R2JoystickImageView;
    
    IBOutlet NSImageView *LHatJoystickImageView;
    IBOutlet NSImageView *RHatJoystickImageView;
    
    IBOutlet NSButton *lockButton;
    
    BOOL isTopPressed;
    BOOL isLeftPressed;
    BOOL isBottomPressed;
    BOOL isRightPressed;
    
    NSSize leftJoystickSize;
    NSSize rightJoystickSize;
    
    NSTimer *joystickUpdateTimer;
   
}

@property  BOOL sendJoysticksWithTimer;
- (void) ddhidJoystick: (DDHidJoystick *)  joystick stick: (unsigned) stick xChanged: (int) value;
- (void) ddhidJoystick: (DDHidJoystick *)  joystick stick: (unsigned) stick yChanged: (int) value;
- (void) ddhidJoystick: (DDHidJoystick *) joystick stick: (unsigned) stick otherAxis: (unsigned) otherAxis valueChanged: (int) value;
- (void) ddhidJoystick: (DDHidJoystick *) joystick buttonDown: (unsigned) buttonNumber;
- (void) ddhidJoystick: (DDHidJoystick *) joystick buttonUp: (unsigned) buttonNumber;


@end

