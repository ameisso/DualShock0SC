#import "AppDelegate.h"


@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [self scan:nil];
    [self createOSC];
    [self load];
    dialValue = 0;
    wheelValue = 0;
    deviceUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/60.0 target:self selector:@selector(updateDevice:) userInfo:nil repeats:YES];
}

- (void)dealloc
{
    [deviceUpdateTimer invalidate];
    deviceUpdateTimer = nil;
}

- (void) updateDevice:(NSTimer *)timer
{
    for (DDHidElement *element in hidElements)
    {
        if( element.cookie == BUTTON_1 && isButton1Pressed != [hidDevice getElementValue:element] )
        {
            isButton1Pressed = [hidDevice getElementValue:element];
            [self sendMessageWithAddress:button1TextField.stringValue andValue:isButton1Pressed];
            [button1ImageView setImage:isButton1Pressed?self.pressedImage:self.releasedImage];
        }
        else if( element.cookie == BUTTON_2 && isButton2Pressed != [hidDevice getElementValue:element] )
        {
            isButton2Pressed = [hidDevice getElementValue:element];
            [self sendMessageWithAddress:button2TextField.stringValue andValue:isButton2Pressed];
            [button2ImageView setImage:isButton2Pressed?self.pressedImage:self.releasedImage];
        }
        else if( element.cookie == BUTTON_3 && isButton3Pressed != [hidDevice getElementValue:element] )
        {
            isButton3Pressed = [hidDevice getElementValue:element];
            [self sendMessageWithAddress:button3TextField.stringValue andValue:isButton3Pressed];
            [button3ImageView setImage:isButton3Pressed?self.pressedImage:self.releasedImage];
        }
        else if( element.cookie == BUTTON_4 && isButton4Pressed != [hidDevice getElementValue:element] )
        {
            isButton4Pressed = [hidDevice getElementValue:element];
            [self sendMessageWithAddress:button4TextField.stringValue andValue:isButton4Pressed];
            [button4ImageView setImage:isButton4Pressed?self.pressedImage:self.releasedImage];
        }
        else if( element.cookie == BUTTON_5 && isButton5Pressed != [hidDevice getElementValue:element] )
        {
            isButton5Pressed = [hidDevice getElementValue:element];
            [self sendMessageWithAddress:button5TextField.stringValue andValue:isButton5Pressed];
            [button5ImageView setImage:isButton5Pressed?self.pressedImage:self.releasedImage];
        }
        else if( element.cookie == WHEEL && wheelValue != [hidDevice getElementValue:element] )
        {
            wheelValue = [hidDevice getElementValue:element];
            [self sendMessageWithAddress:wheelTextField.stringValue andFloatValue:wheelValue/7.0*wheelSensivityTextField.floatValue];
            [wheelImageView setImage:self.pressedImage];
        }
        else if( element.cookie == WHEEL && wheelValue == [hidDevice getElementValue:element] )
        {
            [wheelImageView setImage:self.releasedImage];
        }
        else if( element.cookie == DIAL && dialValue != [hidDevice getElementValue:element] )
        {
            dialValue = [hidDevice getElementValue:element];
            [self sendMessageWithAddress:dialTextField.stringValue andValue:(int)dialValue];
            [dialImageView setImage:self.pressedImage];
        }
        else if( element.cookie == DIAL && dialValue == [hidDevice getElementValue:element] )
        {
            [dialImageView setImage:self.releasedImage];
        }
    }
    if( self.sendWheelWithTimer )
    {
        [self sendMessageWithAddress:wheelTextField.stringValue andFloatValue:wheelValue/7.0*wheelSensivityTextField.floatValue];
        [self sendMessageWithAddress:dialTextField.stringValue andValue:dialValue];
    }
}

- (IBAction)scan:(id)sender
{
    devices = [DDHidDevice allDevices ];
    for( DDHidDevice *device in devices )
    {
        if([device.manufacturer isEqualToString:@"Contour Design"])
        {
            hidDevice = device;
            [hidDevice setListenInExclusiveMode:YES];
            [hidDevice startListening];
            NSArray *elements = hidDevice.elements;
            DDHidElement *firstElement = elements.firstObject;
            hidElements = [[firstElement.elements firstObject] elements];
        }
        [self oscOutputsChangedNotification:nil];
    }
}

- (IBAction)lockButtonAction:(NSButton *)sender
{
    if( sender.state == 0 )
    {
        [lockButton setImage:[NSImage imageNamed:@"unlock"]];
    }
    else
    {
        [lockButton setImage:[NSImage imageNamed:@"lock"]];
    }
    [self updateTextField:button1TextField withLock:sender.state];
    [self updateTextField:button2TextField withLock:sender.state];
    [self updateTextField:button3TextField withLock:sender.state];
    [self updateTextField:button4TextField withLock:sender.state];
    
    [self updateTextField:button5TextField withLock:sender.state];
    [self updateTextField:wheelTextField withLock:sender.state];
    [self updateTextField:dialTextField withLock:sender.state];
}

- (void)updateTextField:(NSTextField *)field withLock:(BOOL)isLocked
{
    if( isLocked )
    {
        [field setEditable:NO];
        [field setBackgroundColor:NSColor.lightGrayColor];
        
    }
    else
    {
        [field setEditable:YES];
        [field setBackgroundColor:NSColor.whiteColor];
    }
}
- (void)applicationWillTerminate:(NSNotification *)aNotification
{
    [self save];
}

- (float)getJoystickSensivity
{
    // return [JoystickSensivityTextField floatValue];
    return 1;
}
#pragma mark OSC
- (void)createOSC
{
    [outPortImageView setImage:self.errorImage];
    oscManager = [[OSCManager alloc] init];
    [oscManager setDelegate:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(oscOutputsChangedNotification:) name:OSCOutPortsChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(oscOutputsChangedNotification:) name:OSCInPortsChangedNotification object:nil];
    
    [self oscOutputsChangedNotification:nil];
}

- (void) oscOutputsChangedNotification:(NSNotification *)notification
{
    [oscTargetPopUpButton removeAllItems];
    NSArray *portLabelArray = [oscManager outPortLabelArray];
    [oscTargetPopUpButton addItemsWithTitles:portLabelArray];
    
    NSString *portLabel = [[[NSUserDefaults standardUserDefaults] objectForKey:@"outPortSnapshot"] objectForKey:@"portLabel"];
    
    outPort = [oscManager findOutputWithLabel:portLabel];
    [oscTargetPopUpButton selectItemWithTitle:portLabel];
}

- (IBAction)targetButtonChanged:(id)sender
{
    int	selectedIndex = (int)[oscTargetPopUpButton indexOfSelectedItem];
    outPort = nil;
    [outPortImageView setImage:self.errorImage];
    if (selectedIndex == -1)
    {
        return;
    }
    outPort = [oscManager findOutputForIndex:selectedIndex];
    [[NSUserDefaults standardUserDefaults] setObject:outPort.createSnapshot forKey:@"outPortSnapshot"];
}

- (void)sendMessageWithAddress:(NSString*)address andValue:(int)value
{
    OSCMessage *oscMessage = [OSCMessage createWithAddress:address];
    [oscMessage addInt:value];
    [outPort sendThisMessage:oscMessage];
    if (outPort)
    {
        [outPortImageView setImage:self.pressedImage];
    }
    else
    {
        [outPortImageView setImage:self.errorImage];
    }
    
    [self save];
}

- (void)sendMessageWithAddress:(NSString*)address andFloatValue:(float)value
{
    OSCMessage *oscMessage = [OSCMessage createWithAddress:address];
    [oscMessage addFloat:value];
    [outPort sendThisMessage:oscMessage];
}

- (void)sendMessageWithAddress:(NSString*)address XValue:(float) xValue andYValue:(float)yValue
{
    OSCMessage *oscMessage = [OSCMessage createWithAddress:address];
    [oscMessage addFloat:xValue];
    [oscMessage addFloat:yValue];
    [outPort sendThisMessage:oscMessage];
    
    NSString *xAddress = [NSString stringWithFormat:@"%@/x",address];
    OSCMessage *xMessage = [OSCMessage createWithAddress:xAddress];
    [xMessage addFloat:xValue];
    [outPort sendThisMessage:xMessage];
    
    NSString *yAddress = [NSString stringWithFormat:@"%@/y",address];
    OSCMessage *yMessage = [OSCMessage createWithAddress:yAddress];
    [yMessage addFloat:yValue];
    [outPort sendThisMessage:yMessage];
    [self updateJoysticksImages];
    
}

#pragma mark IMAGES

- (NSImage*)pressedImage
{
    return [NSImage imageNamed:@"NSStatusAvailable"];
}

- (NSImage*)releasedImage
{
    return [NSImage imageNamed:@"NSStatusNone"];
}

- (NSImage*)errorImage
{
    return [NSImage imageNamed:@"NSStatusUnavailable"];
}

- (void)updateJoysticksImages
{
    //    float unMappedLeftX = [self map:leftJoystickSize.width inMin:0 inMax:1 outMin:-65536 outMax:65536];
    //    float unMappedLeftY = [self map:leftJoystickSize.width inMin:0 inMax:1 outMin:-65536 outMax:65536];
    //    if(unMappedLeftX > -3000 && unMappedLeftX < 3000 && unMappedLeftY > -3000 && unMappedLeftY < 3000)
    //    {
    //        [LHatJoystickImageView setImage:self.releasedImage];
    //    }
    //    else
    //    {
    //        [LHatJoystickImageView setImage:self.pressedImage];
    //    }
    //
    //    float unMappedRightX = [self map:rightJoystickSize.width inMin:0 inMax:1 outMin:-65536 outMax:65536];
    //    float unMappedRightY = [self map:rightJoystickSize.width inMin:0 inMax:1 outMin:-65536 outMax:65536];
    //    if(unMappedRightX > -3000 && unMappedRightX < 3000 && unMappedRightY > -3000 && unMappedRightY < 3000)
    //    {
    //        [RHatJoystickImageView setImage:self.releasedImage];
    //    }
    //    else
    //    {
    //        [RHatJoystickImageView setImage:self.pressedImage];
    //    }
}
#pragma mark CODING
- (void)save
{
    [[NSUserDefaults standardUserDefaults] setObject:button1TextField.stringValue forKey:@"button1"];
    [[NSUserDefaults standardUserDefaults] setObject:button2TextField.stringValue forKey:@"button2"];
    [[NSUserDefaults standardUserDefaults] setObject:button3TextField.stringValue forKey:@"button3"];
    [[NSUserDefaults standardUserDefaults] setObject:button4TextField.stringValue forKey:@"button4"];
    [[NSUserDefaults standardUserDefaults] setObject:button5TextField.stringValue forKey:@"button5"];
    [[NSUserDefaults standardUserDefaults] setObject:dialTextField.stringValue forKey:@"dialField"];
    [[NSUserDefaults standardUserDefaults] setObject:wheelTextField.stringValue forKey:@"wheelField"];
    
    
    [[NSUserDefaults standardUserDefaults] setObject:@(_sendWheelWithTimer) forKey:@"sendWheelWithTimer"];
    [[NSUserDefaults standardUserDefaults] setObject:@(wheelSensivityTextField.floatValue) forKey:@"wheelSensivity"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)load
{
    button1TextField.stringValue = [[NSUserDefaults standardUserDefaults] stringForKey:@"button1"];
    button2TextField.stringValue = [[NSUserDefaults standardUserDefaults] stringForKey:@"button2"];
    button3TextField.stringValue = [[NSUserDefaults standardUserDefaults] stringForKey:@"button3"];
    button4TextField.stringValue = [[NSUserDefaults standardUserDefaults] stringForKey:@"button4"];
    
    button5TextField.stringValue = [[NSUserDefaults standardUserDefaults] stringForKey:@"button5"];
    dialTextField.stringValue = [[NSUserDefaults standardUserDefaults] stringForKey:@"dialField"];
    wheelTextField.stringValue = [[NSUserDefaults standardUserDefaults] stringForKey:@"wheelField"];
    
    self.sendWheelWithTimer =  [[[NSUserDefaults standardUserDefaults] objectForKey:@"sendWheelWithTimer"] boolValue];
    wheelSensivityTextField.floatValue = [[[NSUserDefaults standardUserDefaults] objectForKey:@"wheelSensivity"] floatValue];
}


#pragma mark UTILS

- (float)map:(float)value inMin:(float)inMin inMax:(float)inMax outMin:(float)outMin outMax:(float)outMax
{
    if( inMin == inMax )
    {
        return outMin;
    }
    return (value - inMin) * (outMax - outMin) / (inMax - inMin) + outMin;
}

@end
