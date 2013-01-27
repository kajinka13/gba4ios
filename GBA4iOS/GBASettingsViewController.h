//
//  GBASettingsViewController.h
//  GBA4iOS
//
//  Created by Riley Testut on 6/3/12.
//  Copyright (c) 2012 Testut Tech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GBASettingsViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UISegmentedControl *frameskipSegmentedControl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *portraitSkinSegmentedControl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *landscapeSkinSegmentedControl;
@property (weak, nonatomic) IBOutlet UISwitch *scaledSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *cheatsSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *autoSaveSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *checkForUpdatesSwitch;

- (IBAction)closeSettings:(id)sender;
- (IBAction)changeFrameskip:(id)sender;
- (IBAction)changePortraitSkin:(id)sender;
- (IBAction)changeLandscapeSkin:(id)sender;
- (IBAction)toggleScaled:(id)sender;
- (IBAction)toggleCheats:(id)sender;
- (IBAction)toggleAutoSave:(id)sender;
- (IBAction)toggleCheckForUpdates:(id)sender;

@end
