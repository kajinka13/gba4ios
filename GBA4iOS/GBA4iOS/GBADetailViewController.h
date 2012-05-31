//
//  GBADetailViewController.h
//  GBA4iOS
//
//  Created by Riley Testut on 5/23/12.
//  Copyright (c) 2012 Testut Tech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ScreenView.h"

@interface GBADetailViewController : UIViewController <UISplitViewControllerDelegate>

@property (strong, nonatomic) id detailItem;

@property (strong, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

- (IBAction)startEmulator:(id)sender;

@end
