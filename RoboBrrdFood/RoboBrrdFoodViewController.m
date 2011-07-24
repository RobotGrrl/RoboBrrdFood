//
//  RoboBrrdFoodViewController.m
//  RoboBrrdFood
//
//  Created by Erin Kennedy on 11-07-19.
//  Copyright 2011 robotgrrl.com. All rights reserved.
//

#import "RoboBrrdFoodViewController.h"

@implementation RoboBrrdFoodViewController

float displaceX = 0;
float displaceY = 0;
float startPosX = 0;
float startPosY = 0;
CGRect mouthRect;
int count = 0;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - RscMgrDelegate Methods

- (void) cableConnected:(NSString *)protocol {
    [manager setBaud:9600];
	[manager open]; 
    UIImage *img = [UIImage imageNamed:@"GreenLight.png"];
    connectedIndicator.image = img;
}

- (void) cableDisconnected {
    UIImage *img = [UIImage imageNamed:@"RedLight.png"];
    connectedIndicator.image = img;	
}

- (void) portStatusChanged {
    
}

- (void) readBytesAvailable:(UInt32)numBytes {
    
}

- (BOOL) rscMessageReceived:(UInt8 *)msg TotalLength:(int)len {
    return FALSE;    
}

- (void) didReceivePortConfig {
}


#pragma mark - Touches

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [[event allTouches] anyObject];
    UIView *touchedView = [touch view];
    
    if(touchedView != self.view) {
        
        // Send data
        txBuffer[0] = [touchedView tag];
        txBuffer[1] = 1;
        int bytesWritten = [manager write:txBuffer Length:2];
        
        // Play sound
        SystemSoundID rustle;
        AudioServicesCreateSystemSoundID(CFBundleCopyResourceURL(CFBundleGetMainBundle(), CFSTR("rustle"), CFSTR("wav"), NULL), &rustle);
        AudioServicesPlaySystemSound(rustle);
        
        // Get start positions
        CGPoint location = [touch locationInView:self.view];
        displaceX = location.x - touchedView.center.x;        
        displaceY = location.y - touchedView.center.y;        
        startPosX = location.x - displaceX;
        startPosY = location.y - displaceY;
    }
    
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [[event allTouches] anyObject];
    UIView *touchedView = [touch view];
    
    if(touchedView != self.view) {
        
        // Move touches
        CGPoint location = [touch locationInView:self.view];
        location.x = location.x - displaceX;
        location.y = location.y - displaceY;
        touchedView.center = location;
    }
     
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {

    UITouch *touch = [[event allTouches] anyObject];
    UIView *touchedView = [touch view];
    
    if(touchedView != self.view) {
        
        // Eat it!
        if(CGRectContainsRect(mouthRect, touchedView.frame)) {
            
            // Send data
            txBuffer[0] = [touchedView tag];
            txBuffer[1] = 2;
            int bytesWritten = [manager write:txBuffer Length:2];
            
            // Play sound
            SystemSoundID crunch;
            AudioServicesCreateSystemSoundID(CFBundleCopyResourceURL(CFBundleGetMainBundle(), CFSTR("crunch"), CFSTR("wav"), NULL), &crunch);
            AudioServicesPlaySystemSound(crunch);
            
            // Handle stuff
            [touchedView setHidden:YES];
            count++;
            
        }
    }
        
    // Burp if full!
    if(count == 5) {
        SystemSoundID belch;
        AudioServicesCreateSystemSoundID(CFBundleCopyResourceURL(CFBundleGetMainBundle(), CFSTR("belch"), CFSTR("wav"), NULL), &belch);
        AudioServicesPlaySystemSound(belch);
    }
    
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    mouthRect = mouth.frame;
    manager = [[RscMgr alloc] init]; 
	[manager setDelegate:self];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

@end
