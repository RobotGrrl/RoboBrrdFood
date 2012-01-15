//
//  RoboBrrdFoodViewController.h
//  RoboBrrdFood
//
//  Created by Erin Kennedy on 11-07-19.
//  Copyright 2011 robotgrrl.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>

#import "RscMgr.h"

#define BUFFER_LEN 1024

@interface RoboBrrdFoodViewController : UIViewController <RscMgrDelegate> {
    
    // Redpark SDK
    RscMgr *manager;
    UInt8 rxBuffer[BUFFER_LEN];
    UInt8 txBuffer[BUFFER_LEN];
    
    // Views
    IBOutlet UIView *banana;
    IBOutlet UIView *blueberry;
    IBOutlet UIView *raspberry;
    IBOutlet UIView *strawberry;
    IBOutlet UIView *watermelon;
    IBOutlet UIView *mouth;
    
    // Connected
    IBOutlet UIImageView *connectedIndicator;
    
    // Arrays
    NSArray *allFruitVC;
    NSArray *fruitPositionsX;
    NSArray *fruitPositionsY;
    
}

@end
