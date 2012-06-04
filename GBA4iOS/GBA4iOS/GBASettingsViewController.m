//
//  GBASettingsViewController.m
//  GBA4iOS
//
//  Created by Riley Testut on 6/3/12.
//  Copyright (c) 2012 Testut Tech. All rights reserved.
//

#import "GBASettingsViewController.h"
#import "GBAAppDelegate.h"
#import "../../iGBA/iphone/gpSPhone/src/gpSPhone_iPhone.h"

@interface GBASettingsViewController ()

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

    
    self.frameskipSegmentedControl.selectedSegmentIndex = preferences.frameSkip;
    self.scaledSwitch.on = preferences.scaled;
    self.portraitSkinSegmentedControl.selectedSegmentIndex = preferences.selectedPortraitSkin;
    self.landscapeSkinSegmentedControl.selectedSegmentIndex = preferences.selectedLandscapeSkin;
    self.cheatsSwitch.on = preferences.cheating;
    
    
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
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - Change Settings

- (IBAction)changeFrameskip:(id)sender {
    [[NSUserDefaults standardUserDefaults] setInteger:self.frameskipSegmentedControl.selectedSegmentIndex forKey:@"frameskip"];
}

- (IBAction)changePortraitSkin:(id)sender {
    [[NSUserDefaults standardUserDefaults] setInteger:self.portraitSkinSegmentedControl.selectedSegmentIndex forKey:@"portraitSkin"];
}

- (IBAction)changeLandscapeSkin:(id)sender {
    [[NSUserDefaults standardUserDefaults] setInteger:self.landscapeSkinSegmentedControl.selectedSegmentIndex forKey:@"landscapeSkin"];
}

- (IBAction)toggleScaled:(id)sender {
    [[NSUserDefaults standardUserDefaults] setBool:self.scaledSwitch.on forKey:@"scaled"];
}

- (IBAction)toggleCheats:(id)sender {
    [[NSUserDefaults standardUserDefaults] setBool:self.cheatsSwitch.on forKey:@"cheatsEnabled"];
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
    GBAAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    
    [appDelegate updatePreferences];
    
    [self.presentingViewController dismissModalViewControllerAnimated:YES];
}
@end
