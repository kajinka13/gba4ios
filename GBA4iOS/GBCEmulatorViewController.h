//
//  GBCEmulatorViewController.h
//  GBA4iOS
//
//  Created by Riley Testut on 1/3/13.
//  Copyright (c) 2013 Testut Tech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GBCControllerViewController.h"

@interface GBCEmulatorViewController : UIViewController <GBCControllerDelegate>

@property (nonatomic, readonly) NSString *romFilepath;

- (id)initWithROMFilepath:(NSString *)filepath;

@end
