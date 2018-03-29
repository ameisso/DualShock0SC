#import "AppDelegate.h"


@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [self scan:nil];
    [self createOSC];
    [self load];
    leftJoystickSize = NSZeroSize;
    rightJoystickSize = NSZeroSize;
    joystickUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/60.0 target:self selector:@selector(updateJoysticks:) userInfo:nil repeats:YES];
}

- (void)dealloc
{
    [joystickUpdateTimer invalidate];
    joystickUpdateTimer = nil;
}

- (void) updateJoysticks:(NSTimer *)timer
{
    if( self.sendJoysticksWithTimer )
    {
        if( fabs(leftJoystickSize.width) > 0.1 || fabs(leftJoystickSize.height) > 0.1 )
        {
            [self sendMessageWithAddress:LHatJoysticktextField.stringValue XValue:leftJoystickSize.width andYValue:leftJoystickSize.height];
        }
        if( fabs(rightJoystickSize.width) > 0.1 || fabs(rightJoystickSize.height) > 0.1 )
        {
            [self sendMessageWithAddress:RHatJoysticktextField.stringValue XValue:rightJoystickSize.width andYValue:rightJoystickSize.height];
        }
    }
}

- (IBAction)scan:(id)sender
{
    joysticks = [DDHidJoystick allJoysticks];
    [joysticks makeObjectsPerformSelector: @selector(setDelegate:) withObject: self];
    for( DDHidJoystick *joystick in joysticks )
    {
        NSLog(@"%@ joysticks %d buttons %d",joystick.productName,joystick.countOfSticks,joystick.numberOfButtons);
        [joystick startListening];
    }
    [self oscOutputsChangedNotification:nil];
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
    [self updateTextField:triangleTextField withLock:sender.state];
    [self updateTextField:circleTextField withLock:sender.state];
    [self updateTextField:crossTextField withLock:sender.state];
    [self updateTextField:squareTextField withLock:sender.state];
    
    [self updateTextField:topTextField withLock:sender.state];
    [self updateTextField:rightTextField withLock:sender.state];
    [self updateTextField:bottomTextField withLock:sender.state];
    [self updateTextField:leftTextField withLock:sender.state];
    
    [self updateTextField:L1TextField withLock:sender.state];
    [self updateTextField:L2TextField withLock:sender.state];
    [self updateTextField:R1TextField withLock:sender.state];
    [self updateTextField:R2TextField withLock:sender.state];
    
    [self updateTextField:LeftHatButtonTextField withLock:sender.state];
    [self updateTextField:RightHatButtonTextField withLock:sender.state];
    
    [self updateTextField:L2JoysticktextField withLock:sender.state];
    [self updateTextField:R2JoysticktextField withLock:sender.state];
    
    [self updateTextField:LHatJoysticktextField withLock:sender.state];
    [self updateTextField:RHatJoysticktextField withLock:sender.state];
    
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
- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (float)getJoystickSensivity
{
    return [JoystickSensivityTextField floatValue];
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

#pragma mark JOYSTICKS
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

- (void) ddhidJoystick: (DDHidJoystick *) joystick buttonDown: (unsigned) buttonNumber;
{
    switch (buttonNumber)
    {
        case TRIANGLE_BUTTON:
            [triangleImageView setImage:[self pressedImage]];
            [self sendMessageWithAddress:triangleTextField.stringValue andValue:1];
            break;
            
        case CIRCLE_BUTTON:
            [circleImageView setImage:[self pressedImage]];
            [self sendMessageWithAddress:circleTextField.stringValue andValue:1];
            break;
            
        case CROSS_BUTTON:
            [crossImageView setImage:[self pressedImage]];
            [self sendMessageWithAddress:crossTextField.stringValue andValue:1];
            break;
            
        case SQUARE_BUTTON:
            [squareImageView setImage:[self pressedImage]];
            [self sendMessageWithAddress:squareTextField.stringValue andValue:1];
            break;
            
        case L1_BUTTON:
            [L1ImageView setImage:[self pressedImage]];
            [self sendMessageWithAddress:L1TextField.stringValue andValue:1];
            break;
            
        case L2_BUTTON:
            [L2tImageView setImage:[self pressedImage]];
            [self sendMessageWithAddress:L2TextField.stringValue andValue:1];
            break;
            
        case R1_BUTTON:
            [R1ImageView setImage:[self pressedImage]];
            [self sendMessageWithAddress:R1TextField.stringValue andValue:1];
            break;
            
        case R2_BUTTON:
            [R2ImageView setImage:[self pressedImage]];
            [self sendMessageWithAddress:R2TextField.stringValue andValue:1];
            break;
            
        case LEFT_HAT_BUTTON:
            [LeftHatButtonImageView setImage:[self pressedImage]];
            [self sendMessageWithAddress:LeftHatButtonTextField.stringValue andValue:1];
            break;
            
        case RIGHT_HAT_BUTTON:
            [RightHatButtonImageView setImage:[self pressedImage]];
            [self sendMessageWithAddress:RightHatButtonTextField.stringValue andValue:1];
            break;
            
            
        default:
            break;
    }
}

- (void)ddhidJoystick:(DDHidJoystick *)joystick buttonUp:(unsigned int)buttonNumber
{
    switch (buttonNumber)
    {
        case TRIANGLE_BUTTON:
            [triangleImageView setImage:[self releasedImage]];
            [self sendMessageWithAddress:triangleTextField.stringValue andValue:0];
            break;
            
        case CIRCLE_BUTTON:
            [circleImageView setImage:[self releasedImage]];
            [self sendMessageWithAddress:circleTextField.stringValue andValue:0];
            break;
            
        case CROSS_BUTTON:
            [crossImageView setImage:[self releasedImage]];
            [self sendMessageWithAddress:crossTextField.stringValue andValue:0];
            break;
            
        case SQUARE_BUTTON:
            [squareImageView setImage:[self releasedImage]];
            [self sendMessageWithAddress:squareTextField.stringValue andValue:0];
            break;
            
        case L1_BUTTON:
            [L1ImageView setImage:[self releasedImage]];
            [self sendMessageWithAddress:L1TextField.stringValue andValue:0];
            break;
            
        case L2_BUTTON:
            [L2tImageView setImage:[self releasedImage]];
            [self sendMessageWithAddress:L2TextField.stringValue andValue:0];
            break;
            
            
        case R1_BUTTON:
            [R1ImageView setImage:[self releasedImage]];
            [self sendMessageWithAddress:R1TextField.stringValue andValue:0];
            break;
            
        case R2_BUTTON:
            [R2ImageView setImage:[self releasedImage]];
            [self sendMessageWithAddress:R2TextField.stringValue andValue:0];
            break;
            
        case LEFT_HAT_BUTTON:
            [LeftHatButtonImageView setImage:[self releasedImage]];
            [self sendMessageWithAddress:LeftHatButtonTextField.stringValue andValue:0];
            break;
            
        case RIGHT_HAT_BUTTON:
            [RightHatButtonImageView setImage:[self releasedImage]];
            [self sendMessageWithAddress:RightHatButtonTextField.stringValue andValue:0];
            break;
            
        default:
            break;
    }
}

- (void) ddhidJoystick: (DDHidJoystick *)  joystick stick: (unsigned) stick xChanged: (int) value
{
    float mappedValue = [self map:value inMin:-65536 inMax:65536 outMin:-self.getJoystickSensivity outMax:self.getJoystickSensivity];
    leftJoystickSize.width = mappedValue;
    if( ! self.sendJoysticksWithTimer )
    {
        [self sendMessageWithAddress:LHatJoysticktextField.stringValue XValue:leftJoystickSize.width andYValue:leftJoystickSize.height];
    }
}

- (void) ddhidJoystick: (DDHidJoystick *)  joystick stick: (unsigned) stick yChanged: (int) value
{
    float mappedValue = [self map:value inMin:-65536 inMax:65536 outMin:self.getJoystickSensivity outMax:-self.getJoystickSensivity];
    leftJoystickSize.height = mappedValue;
    if( ! self.sendJoysticksWithTimer )
    {
        [self sendMessageWithAddress:LHatJoysticktextField.stringValue XValue:leftJoystickSize.width andYValue:leftJoystickSize.height];
    }
}

- (void) ddhidJoystick: (DDHidJoystick *) joystick stick: (unsigned) stick otherAxis: (unsigned) otherAxis valueChanged: (int) value;
{
    BOOL shouldSendRightJoystick = NO;
    float mappedValue = [self map:value inMin:-65536 inMax:65536 outMin:0 outMax:1];
    switch (otherAxis)
    {
        case L2_JOYSTICK:
            if(value == -65536)
            {
                [L2JoystickImageView setImage:self.releasedImage];
            }
            else
            {
                [L2JoystickImageView setImage:self.pressedImage];
            }
            [self sendMessageWithAddress:L2JoysticktextField.stringValue andFloatValue:mappedValue];
            break;
        case R2_JOYSTICK:
            if(value == -65536)
            {
                [R2JoystickImageView setImage:self.releasedImage];
            }
            else
            {
                [R2JoystickImageView setImage:self.pressedImage];
            }
            [self sendMessageWithAddress:R2JoysticktextField.stringValue andFloatValue:mappedValue];
            break;
        case RIGHT_JOYSTICK_X:
            mappedValue = [self map:value inMin:-65536 inMax:65536 outMin:-self.getJoystickSensivity outMax:self.getJoystickSensivity];
            rightJoystickSize.width = mappedValue;
            shouldSendRightJoystick = YES;
            break;
        case RIGHT_JOYSTICK_Y:
            mappedValue = [self map:value inMin:-65536 inMax:65536 outMin:self.getJoystickSensivity outMax:-self.getJoystickSensivity];
            rightJoystickSize.height = mappedValue;
            shouldSendRightJoystick = YES;
            break;
            
            
        default:
            break;
    }
    if( shouldSendRightJoystick && ! self.sendJoysticksWithTimer )
    {
        [self sendMessageWithAddress:RHatJoysticktextField.stringValue XValue:rightJoystickSize.width andYValue:rightJoystickSize.height];
    }
}

- (void) ddhidJoystick: (DDHidJoystick *) joystick stick: (unsigned) stick povNumber: (unsigned) povNumber valueChanged: (int) value;
{
    switch (value)
    {
        case 0:
            isTopPressed = YES;
            break;
        case 4500:
            isTopPressed = YES;
            isRightPressed = YES;
            break;
        case 9000:
            isRightPressed = YES;
            break;
        case 13500:
            isRightPressed = YES;
            isBottomPressed = YES;
            break;
        case 18000:
            isBottomPressed = YES;
            break;
        case 22500:
            isBottomPressed = YES;
            isLeftPressed = YES;
            break;
        case 27000:
            isLeftPressed = YES;
            break;
        case 31500:
            isLeftPressed = YES;
            isTopPressed = YES;
            break;
        default: //-1 release
            if (isTopPressed)
            {
                [self sendMessageWithAddress:topTextField.stringValue andValue:0];
                [topImageView setImage:self.releasedImage];
                isTopPressed = NO;
            }
            if (isRightPressed)
            {
                [self sendMessageWithAddress:rightTextField.stringValue andValue:0];
                [rightImageView setImage:self.releasedImage];
                isRightPressed = NO;
            }
            if (isBottomPressed)
            {
                [self sendMessageWithAddress:bottomTextField.stringValue andValue:0];
                [bottomImageView setImage:self.releasedImage];
                isBottomPressed = NO;
            }
            if (isLeftPressed)
            {
                [self sendMessageWithAddress:leftTextField.stringValue andValue:0];
                [leftImageView setImage:self.releasedImage];
                isLeftPressed = NO;
            }
            break;
    }
    if (isTopPressed)
    {
        [self sendMessageWithAddress:topTextField.stringValue andValue:1];
        [topImageView setImage:self.pressedImage];
    }
    if (isRightPressed)
    {
        [self sendMessageWithAddress:rightTextField.stringValue andValue:1];
        [rightImageView setImage:self.pressedImage];
    }
    if (isBottomPressed)
    {
        [self sendMessageWithAddress:bottomTextField.stringValue andValue:1];
        [bottomImageView setImage:self.pressedImage];
    }
    if (isLeftPressed)
    {
        [self sendMessageWithAddress:leftTextField.stringValue andValue:1];
        [leftImageView setImage:self.pressedImage];
    }
}

- (void)updateJoysticksImages
{
    float unMappedLeftX = [self map:leftJoystickSize.width inMin:0 inMax:1 outMin:-65536 outMax:65536];
    float unMappedLeftY = [self map:leftJoystickSize.width inMin:0 inMax:1 outMin:-65536 outMax:65536];
    if(unMappedLeftX > -3000 && unMappedLeftX < 3000 && unMappedLeftY > -3000 && unMappedLeftY < 3000)
    {
        [LHatJoystickImageView setImage:self.releasedImage];
    }
    else
    {
        [LHatJoystickImageView setImage:self.pressedImage];
    }
    
    float unMappedRightX = [self map:rightJoystickSize.width inMin:0 inMax:1 outMin:-65536 outMax:65536];
    float unMappedRightY = [self map:rightJoystickSize.width inMin:0 inMax:1 outMin:-65536 outMax:65536];
    if(unMappedRightX > -3000 && unMappedRightX < 3000 && unMappedRightY > -3000 && unMappedRightY < 3000)
    {
        [RHatJoystickImageView setImage:self.releasedImage];
    }
    else
    {
        [RHatJoystickImageView setImage:self.pressedImage];
    }
    
}
#pragma mark CODING
- (void)save
{
    [[NSUserDefaults standardUserDefaults] setObject:triangleTextField.stringValue forKey:@"triangleTextField"];
    [[NSUserDefaults standardUserDefaults] setObject:circleTextField.stringValue forKey:@"circleTextField"];
    [[NSUserDefaults standardUserDefaults] setObject:crossTextField.stringValue forKey:@"crossTextField"];
    [[NSUserDefaults standardUserDefaults] setObject:squareTextField.stringValue forKey:@"squareTextField"];
    
    [[NSUserDefaults standardUserDefaults] setObject:topTextField.stringValue forKey:@"topTextField"];
    [[NSUserDefaults standardUserDefaults] setObject:rightTextField.stringValue forKey:@"rightTextField"];
    [[NSUserDefaults standardUserDefaults] setObject:bottomTextField.stringValue forKey:@"bottomTextField"];
    [[NSUserDefaults standardUserDefaults] setObject:leftTextField.stringValue forKey:@"leftTextField"];
    
    [[NSUserDefaults standardUserDefaults] setObject:L1TextField.stringValue forKey:@"L1TextField"];
    [[NSUserDefaults standardUserDefaults] setObject:L2TextField.stringValue forKey:@"L2TextField"];
    [[NSUserDefaults standardUserDefaults] setObject:R1TextField.stringValue forKey:@"R1TextField"];
    [[NSUserDefaults standardUserDefaults] setObject:R2TextField.stringValue forKey:@"R2TextField"];
    
    [[NSUserDefaults standardUserDefaults] setObject:LeftHatButtonTextField.stringValue forKey:@"LeftHatButtonTextField"];
    [[NSUserDefaults standardUserDefaults] setObject:RightHatButtonTextField.stringValue forKey:@"RightHatButtonTextField"];
    
    [[NSUserDefaults standardUserDefaults] setObject:L2JoysticktextField.stringValue forKey:@"L2JoysticktextField"];
    [[NSUserDefaults standardUserDefaults] setObject:R2JoysticktextField.stringValue forKey:@"R2JoysticktextField"];
    
    [[NSUserDefaults standardUserDefaults] setObject:LHatJoysticktextField.stringValue forKey:@"LHatJoysticktextField"];
    [[NSUserDefaults standardUserDefaults] setObject:RHatJoysticktextField.stringValue forKey:@"RHatJoysticktextField"];
    
     [[NSUserDefaults standardUserDefaults] setObject:@(_sendJoysticksWithTimer) forKey:@"sendJoysticksWithTimer"];
    [[NSUserDefaults standardUserDefaults] setObject:@(JoystickSensivityTextField.floatValue) forKey:@"joystickSensivity"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)load
{
    triangleTextField.stringValue = [[NSUserDefaults standardUserDefaults] stringForKey:@"triangleTextField"];
    circleTextField.stringValue = [[NSUserDefaults standardUserDefaults] stringForKey:@"circleTextField"];
    crossTextField.stringValue = [[NSUserDefaults standardUserDefaults] stringForKey:@"crossTextField"];
    squareTextField.stringValue = [[NSUserDefaults standardUserDefaults] stringForKey:@"squareTextField"];
    
    topTextField.stringValue = [[NSUserDefaults standardUserDefaults] stringForKey:@"topTextField"];
    rightTextField.stringValue = [[NSUserDefaults standardUserDefaults] stringForKey:@"rightTextField"];
    bottomTextField.stringValue = [[NSUserDefaults standardUserDefaults] stringForKey:@"bottomTextField"];
    leftTextField.stringValue = [[NSUserDefaults standardUserDefaults] stringForKey:@"leftTextField"];
    
    L1TextField.stringValue = [[NSUserDefaults standardUserDefaults] stringForKey:@"L1TextField"];
    L2TextField.stringValue = [[NSUserDefaults standardUserDefaults] stringForKey:@"L2TextField"];
    R1TextField.stringValue = [[NSUserDefaults standardUserDefaults] stringForKey:@"R1TextField"];
    R2TextField.stringValue = [[NSUserDefaults standardUserDefaults] stringForKey:@"R2TextField"];
    
    LeftHatButtonTextField.stringValue = [[NSUserDefaults standardUserDefaults] stringForKey:@"LeftHatButtonTextField"];
    RightHatButtonTextField.stringValue = [[NSUserDefaults standardUserDefaults] stringForKey:@"RightHatButtonTextField"];
    
    L2JoysticktextField.stringValue = [[NSUserDefaults standardUserDefaults] stringForKey:@"L2JoysticktextField"];
    R2JoysticktextField.stringValue = [[NSUserDefaults standardUserDefaults] stringForKey:@"R2JoysticktextField"];
    
    LHatJoysticktextField.stringValue = [[NSUserDefaults standardUserDefaults] stringForKey:@"LHatJoysticktextField"];
    RHatJoysticktextField.stringValue = [[NSUserDefaults standardUserDefaults] stringForKey:@"RHatJoysticktextField"];
    
    self.sendJoysticksWithTimer =  [[[NSUserDefaults standardUserDefaults] objectForKey:@"sendJoysticksWithTimer"] boolValue];
    JoystickSensivityTextField.floatValue = [[[NSUserDefaults standardUserDefaults] objectForKey:@"joystickSensivity"] floatValue];
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
