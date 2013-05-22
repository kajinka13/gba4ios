//
//  GBAMasterViewController.h
//  GBA4iOS
//
//  Created by Riley Testut on 5/23/12.
//  Copyright (c) 2012 Testut Tech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GBAEmulatorViewController.h"

@class GBADetailViewController;

@interface GBAMasterViewController : UITableViewController <UIAlertViewDelegate>

@property (strong, nonatomic) GBADetailViewController *detailViewController;
@property (copy, nonatomic) NSString *currentRomPath;

- (IBAction)scanRomDirectory;
- (IBAction)getMoreROMs;

@end
