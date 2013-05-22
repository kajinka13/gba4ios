//
//  GBASettingsViewController.m
//  GBA4iOS
//
//  Created by Riley Testut on 6/3/12.
//  Copyright (c) 2012 Testut Tech. All rights reserved.
//

#import "GBASettingsViewController.h"
#import "GBAAppDelegate.h"
#import "GBASettingsManager.h"

@interface GBASettingsViewController ()

@property (copy, nonatomic) NSDictionary *footerDictionary;

@end

@implementation GBASettingsViewController
@synthesize frameskipSegmentedControl;
@synthesize portraitSkinSegmentedControl;
@synthesize landscapeSkinSegmentedControl;
@synthesize scaledSwitch;
@synthesize cheatsSwitch;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    
    self.frameskipSegmentedControl.selectedSegmentIndex = [GBASettingsManager sharedManager].frameSkip;
    self.scaledSwitch.on = [GBASettingsManager sharedManager].scaled;
    self.portraitSkinSegmentedControl.selectedSegmentIndex = [GBASettingsManager sharedManager].portraitSkin;
    self.landscapeSkinSegmentedControl.selectedSegmentIndex = [GBASettingsManager sharedManager].landscapeSkin;
    self.cheatsSwitch.on = [GBASettingsManager sharedManager].cheatsEnabled;
    self.autoSaveSwitch.on = [GBASettingsManager sharedManager].autoSave;
    self.checkForUpdatesSwitch.on = [GBASettingsManager sharedManager].checkForUpdates;
    
    [self.tableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:@"HeaderFooterViewIdentifier"];
        
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [self setFrameskipSegmentedControl:nil];
    [self setPortraitSkinSegmentedControl:nil];
    [self setLandscapeSkinSegmentedControl:nil];
    [self setScaledSwitch:nil];
    [self setCheatsSwitch:nil];
    [self setAutoSaveSwitch:nil];
    [self setCheckForUpdatesSwitch:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - Headers/Footers

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    static NSString *HeaderFooterViewIdentifier = @"HeaderFooterViewIdentifier";
    
    UITableViewHeaderFooterView *footerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:HeaderFooterViewIdentifier];
    
    if ([footerView gestureRecognizers] == 0) {
        
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didDetectTap:)];
        [footerView addGestureRecognizer:tapGestureRecognizer];
    }
        
    footerView.tag = section;
    
    return footerView;
}

- (void)didDetectTap:(UITapGestureRecognizer *)tapGestureRecognizer {
    UITableViewHeaderFooterView *footerView = (UITableViewHeaderFooterView *)[tapGestureRecognizer view];
    if (footerView.tag == 2) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://twitter.com/rileytestut"]];
    }
    else if (footerView.tag == 3) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://twitter.com/zodttd"]];
    }
    else if (footerView.tag == 4) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://rocketdock.com/user/35907/addons/popular"]];
    }
    else if (footerView.tag == 5) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://winfisdesign.blogspot.com"]];
    }
}

#pragma mark - Change Settings

- (IBAction)changeFrameskip:(id)sender {
    [[GBASettingsManager sharedManager] setFrameSkip:self.frameskipSegmentedControl.selectedSegmentIndex];
}

- (IBAction)changePortraitSkin:(id)sender {
    [[GBASettingsManager sharedManager] setPortraitSkin:self.portraitSkinSegmentedControl.selectedSegmentIndex];
}

- (IBAction)changeLandscapeSkin:(id)sender {
    [[GBASettingsManager sharedManager] setLandscapeSkin:self.landscapeSkinSegmentedControl.selectedSegmentIndex];
}

- (IBAction)toggleScaled:(id)sender {
    [[GBASettingsManager sharedManager] setScaled:self.scaledSwitch.on];
}

- (IBAction)toggleCheats:(id)sender {
    [[GBASettingsManager sharedManager] setCheatsEnabled:self.cheatsSwitch.on];
}

- (IBAction)toggleAutoSave:(id)sender {
    [[GBASettingsManager sharedManager] setAutoSave:self.autoSaveSwitch.on];
}

- (IBAction)toggleCheckForUpdates:(id)sender {
    [[GBASettingsManager sharedManager] setCheckForUpdates:self.checkForUpdatesSwitch.on];
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

#pragma mark - Dismiss

- (IBAction)closeSettings:(id)sender {
    [self.presentingViewController dismissModalViewControllerAnimated:YES];
}
@end
