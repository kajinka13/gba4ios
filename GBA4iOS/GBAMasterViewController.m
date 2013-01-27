//
//  GBAMasterViewController.m
//  GBA4iOS
//
//  Created by Riley Testut on 5/23/12.
//  Copyright (c) 2012 Testut Tech. All rights reserved.
//

#import "GBAMasterViewController.h"
#import "GBCEmulatorViewController.h"
#import "GBASettingsManager.h"

#import "GBADetailViewController.h"
#import "WebBrowserViewController.h"
#import "GBASettingsViewController.h"

#import <Parse/Parse.h>

#define UPDATE_AVAILABLE_TAG 13

@interface GBAMasterViewController () <UIAlertViewDelegate>
@property (strong, nonatomic) NSMutableDictionary *romDictionary;
@property (strong, nonatomic) NSArray *romSections;
@property (nonatomic) NSInteger currentSection_;
@property (strong, nonatomic) PullToRefreshView *pullToRefreshView_;
@property (copy, nonatomic) NSString *deletingRomPath;
@end

@implementation GBAMasterViewController

@synthesize detailViewController = _detailViewController;
@synthesize romDictionary;
@synthesize romSections;
@synthesize currentSection_;
@synthesize currentRomPath;
@synthesize pullToRefreshView_;
@synthesize deletingRomPath;

- (void)awakeFromNib
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
    }
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.pullToRefreshView_ = [[PullToRefreshView alloc] initWithScrollView:(UIScrollView *) self.tableView];
    [self.pullToRefreshView_ setDelegate:self];
    [self.tableView addSubview:self.pullToRefreshView_];
    
	// Do any additional setup after loading the view, typically from a nib.
    
    self.navigationItem.leftBarButtonItem.landscapeImagePhone = [UIImage imageNamed:@"GearLandscape"];
    
    [self scanRomDirectory];
    
    self.detailViewController = (GBADetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self scanRomDirectory];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if ([[GBASettingsManager sharedManager] checkForUpdates]) {
        [self checkForUpdates];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (void)longTap:(UILongPressGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan) { // This makes it get called only once.
        return;
    }
    
    NSString *filename = [gestureRecognizer.view accessibilityIdentifier];
    if (!filename) {
        return;
    }
    UIAlertView *changeFilename = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Rename File", @"") message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"") otherButtonTitles:NSLocalizedString(@"Done", @""), nil];
    changeFilename.accessibilityIdentifier = filename;
    changeFilename.alertViewStyle = UIAlertViewStylePlainTextInput;
    [changeFilename textFieldAtIndex:0].text = filename;
    
    [changeFilename show];
}

#pragma mark -
#pragma mark ROM loading methods

- (void)pullToRefreshViewShouldRefresh:(PullToRefreshView *)view;
{
    [self scanRomDirectory];
}

- (IBAction)scanRomDirectory {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectoryPath = [paths objectAtIndex:0];
    
    [self.romDictionary removeAllObjects];
    if (!self.romDictionary) {
        self.romDictionary = [[NSMutableDictionary alloc] init];
    }
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSArray *contents = [fileManager contentsOfDirectoryAtPath:documentsDirectoryPath error:nil];
    
    self.romSections = [NSArray arrayWithArray:[@"A|B|C|D|E|F|G|H|I|J|K|L|M|N|O|P|Q|R|S|T|U|V|W|X|Y|Z|#" componentsSeparatedByString:@"|"]];
    
    for (int i = 0; i < contents.count; i++) {
        NSString *filename = [contents objectAtIndex:i];
        if ([filename hasSuffix:@".zip"] || [filename hasSuffix:@".ZIP"] || [filename hasSuffix:@".gba"] || [filename hasSuffix:@".GBA"] || [filename hasSuffix:@".ips"] || [filename hasSuffix:@".IPS"] || [filename hasSuffix:@".gb"] || [filename hasSuffix:@".GB"]) {
            NSString* characterIndex = [filename substringWithRange:NSMakeRange(0,1)];
            
            BOOL matched = NO;
            for (int i = 0; i < self.romSections.count && !matched; i++) {
                NSString *section = [self.romSections objectAtIndex:i];
                if ([section isEqualToString:characterIndex]) {
                    matched = YES;
                }
            }
            
            if (!matched) {
                characterIndex = @"#";
            }
            
            NSMutableArray *sectionArray = [self.romDictionary objectForKey:characterIndex];
            if (sectionArray == nil) {
                sectionArray = [[NSMutableArray alloc] init];
            }
            [sectionArray addObject:filename];
            [self.romDictionary setObject:sectionArray forKey:characterIndex];
        }
    }
    
    [self.tableView reloadData];
    
    [self importSaveStates];
    
    double delayInSeconds = 0.5;//gives the pull to refresh animation time to work, less jerky
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.pullToRefreshView_ finishedLoading];
    });
    
}

- (void) importSaveStates {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *saveStateDirectory = [documentsDirectory stringByAppendingPathComponent:@"Save States"];
    
    NSArray* dirContents = [fileManager contentsOfDirectoryAtPath:documentsDirectory error:nil];
    [dirContents enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *filename = obj;
        if ([filename hasSuffix:@"svs"]) {
            NSError *error = nil;
            NSString *romName = [filename stringByDeletingPathExtension];
            
            NSRange range = NSMakeRange([romName length] - 1, 1);
            NSString *saveSlot = [romName substringWithRange:range];
            NSInteger saveSlotNumber = [saveSlot integerValue];
            NSString *destinationFilename = [NSString stringWithFormat:@"%@.svs", saveSlot];
            
            romName = [romName substringToIndex:[romName length] - 1];
            
            NSString *originalFilePath = [documentsDirectory stringByAppendingPathComponent:filename];
            NSString *romSaveStateDirectory = [saveStateDirectory stringByAppendingPathComponent:romName]; 
            NSString *saveStateInfoPath = [romSaveStateDirectory stringByAppendingPathComponent:@"info.plist"];
            
            [fileManager createDirectoryAtPath:romSaveStateDirectory withIntermediateDirectories:YES attributes:nil error:nil];
            
            NSMutableArray *array = [[NSMutableArray alloc] initWithContentsOfFile:saveStateInfoPath];
            
            if ([array count] == 0) {
                array = [[NSMutableArray alloc] initWithCapacity:5];
                
                for (int i = 0; i < 5; i++) {
                    [array addObject:NSLocalizedString(@"Empty", @"")];
                }
            }
            [array replaceObjectAtIndex:saveSlotNumber withObject:NSLocalizedString(@"Imported", @"")];
            [array writeToFile:saveStateInfoPath atomically:YES];
            
            NSString *destinationFilePath = [romSaveStateDirectory stringByAppendingPathComponent:destinationFilename];
            
            if ([fileManager copyItemAtPath:originalFilePath toPath:destinationFilePath error:&error] && !error) {
                [fileManager removeItemAtPath:originalFilePath error:nil];
                NSLog(@"Successfully copied svs file to svs directory");
            }
            else {
                NSLog(@"%@. %@.", error, [error userInfo]);
            }
        }
    }];
}

#pragma mark - Download ROMs

- (IBAction)getMoreROMs {
    WebBrowserViewController *webViewController = [[WebBrowserViewController alloc] init];
    UINavigationController *webNavController = [[UINavigationController alloc] initWithRootViewController:webViewController];
	webNavController.navigationBar.barStyle = UIBarStyleBlack;
    [self presentModalViewController:webNavController animated:YES];
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = nil;
            
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];        
    }
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    NSString *filename = [[self.romDictionary objectForKey:[self.romSections objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
    filename = [filename stringByDeletingPathExtension];//cleaner interface
    cell.accessibilityIdentifier = filename;
    cell.textLabel.text = filename;
    
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longTap:)];
    
    bool flag = true;
    for (UIGestureRecognizer *gr in cell.gestureRecognizers) {
        if (longPressGesture.class == gr.class) {
            flag = false;
        }
    }
    if (flag) {
        [cell addGestureRecognizer:longPressGesture];
    }
    
    return cell;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger numberOfSections = self.romSections.count;    
    return numberOfSections > 0 ? numberOfSections : 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *sectionTitle = nil;    
    if(self.romSections.count) {
        NSInteger numberOfRows = [self tableView:tableView numberOfRowsInSection:section];
        if (numberOfRows > 0) {
            sectionTitle = [self.romSections objectAtIndex:section];
        }
    }    
    return sectionTitle;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    NSMutableArray *sectionIndexTitles = nil;
    if(self.romSections.count) {
        sectionIndexTitles = [NSMutableArray arrayWithArray:[@"A|B|C|D|E|F|G|H|I|J|K|L|M|N|O|P|Q|R|S|T|U|V|W|X|Y|Z|#" componentsSeparatedByString:@"|"]];
    }
    return  sectionIndexTitles;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    self.currentSection_ = index;
    return index;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numberOfRows = self.romDictionary.count;
    if(self.romSections.count) {
        numberOfRows = [[self.romDictionary objectForKey:[self.romSections objectAtIndex:section]] count];
    }
    return numberOfRows;
}

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

- (NSString *)romPathAtIndexPath:(NSIndexPath *)indexPath {
    return [[self.romDictionary objectForKey:[self.romSections objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectoryPath = [paths objectAtIndex:0];
        
        self.currentRomPath = [documentsDirectoryPath stringByAppendingPathComponent:[self romPathAtIndexPath:indexPath]];
        self.detailViewController.detailItem = self.currentRomPath;
    }
    else if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectoryPath = [paths objectAtIndex:0];
        
        self.currentRomPath = [documentsDirectoryPath stringByAppendingPathComponent:[self romPathAtIndexPath:indexPath]];
        
        [UIApplication sharedApplication].statusBarHidden = YES;
        
        if ([[self.currentRomPath pathExtension] isEqualToString:@"GB"] || [[self.currentRomPath pathExtension] isEqualToString:@"gb"]) { // GBC ROM
            GBCEmulatorViewController *emulatorViewController = [[GBCEmulatorViewController alloc] initWithROMFilepath:self.currentRomPath];
            emulatorViewController.wantsFullScreenLayout = YES;
            
            [self presentViewController:emulatorViewController animated:YES completion:NULL];
        }
        else { // GBA ROM
            GBAEmulatorViewController *emulatorViewController = [[GBAEmulatorViewController alloc] init];
            emulatorViewController.wantsFullScreenLayout = YES;
            emulatorViewController.romPath = self.currentRomPath;
            
            [self presentViewController:emulatorViewController animated:YES completion:NULL];
        }
        
    }
}

- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
	return YES;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return @"Delete";
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(editingStyle == UITableViewCellEditingStyleDelete)
	{
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectoryPath = [paths objectAtIndex:0];
		
		self.deletingRomPath = [documentsDirectoryPath stringByAppendingPathComponent:[self romPathAtIndexPath:indexPath]];
		
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Delete ROM"
															message:@"Also delete save states and save files?"
														   delegate:self
												  cancelButtonTitle:@"Cancel"
												  otherButtonTitles:@"Delete ROM only", @"Delete ROM & saved data", nil];
		[alertView show];
	}
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([alertView.title isEqualToString:NSLocalizedString(@"Rename File", @"")]) { // It works much better now.
        if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:NSLocalizedString(@"Done", @"")]) {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectoryPath = [paths objectAtIndex:0];
            
            __block int (^checkError)(NSError *error) = ^(NSError *error){
                if (error) {
                    NSLog(@"%@", error);
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:error.description delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
                    [alertView show];
                    return 1;
                }
                return 0;
            };
            
            __block void (^parseAndRenameInDirectory)(NSString *dir) = ^(NSString *dir) {
                NSError *error = nil;
                NSFileManager *fm = [NSFileManager defaultManager];
                NSArray *dirContents = [fm contentsOfDirectoryAtPath:dir error:&error];
                
                if (checkError(error)) {
                    return;
                }
                
                for (NSString *file in dirContents) {
                    NSString *fullPath = [dir stringByAppendingPathComponent:file];
                    
                    NSString *newFile = nil;
                    if (![file.pathExtension isEqualToString:@""]) {
                        newFile = [dir stringByAppendingPathComponent:[[alertView textFieldAtIndex:0].text stringByAppendingPathExtension:file.pathExtension]];
                    } else {
                        newFile = [dir stringByAppendingPathComponent:[alertView textFieldAtIndex:0].text];
                    }
                    
                    BOOL isDir = false;
                    [fm fileExistsAtPath:fullPath isDirectory:&isDir];
                    
                    if (isDir) {
                        parseAndRenameInDirectory(fullPath); // Recursive part that makes sure it goes through every folder.
                        
                        // RENAME FOLDER
                        if ([[file stringByDeletingPathExtension] isEqualToString:alertView.accessibilityIdentifier]) {
                            if ([fm fileExistsAtPath:newFile]) {
                                [fm removeItemAtPath:newFile error:&error]; // Removes an existing directory if it is in the way.
                                
                                if (checkError(error)) {
                                    return;
                                }
                            }
                            
                            if (checkError(error)) {
                                return;
                            }
                            
                            NSString *oldDirectoryPath = fullPath;
                            
                            NSArray *tempArrayForContentsOfDirectory =[[NSFileManager defaultManager] contentsOfDirectoryAtPath:oldDirectoryPath error:&error];
                            
                            if (checkError(error)) {
                                return;
                            }
                            
                            NSString *newDirectoryPath = newFile;
                            
                            [fm createDirectoryAtPath:newDirectoryPath withIntermediateDirectories:NO attributes:nil error:&error];
                            
                            if (checkError(error)) {
                                return;
                            }
                            
                            for (int i = 0; i < [tempArrayForContentsOfDirectory count]; i++)
                            {
                                NSString *newFilePath = [newDirectoryPath stringByAppendingPathComponent:
                                                         [tempArrayForContentsOfDirectory objectAtIndex:i]];
                                
                                NSString *oldFilePath = [oldDirectoryPath stringByAppendingPathComponent:
                                                         [tempArrayForContentsOfDirectory objectAtIndex:i]];
                                
                                [fm moveItemAtPath:oldFilePath toPath:newFilePath error:&error];
                                
                                if (checkError(error)) {
                                    return;
                                }
                            }
                            
                            if ([[fm contentsOfDirectoryAtPath:oldDirectoryPath error:nil] count] == 0 && [[fm contentsOfDirectoryAtPath:newDirectoryPath error:nil] count] > 0) {
                                [fm removeItemAtPath:oldDirectoryPath error:&error];
                                
                                if (checkError(error)) {
                                    return;
                                }
                            }
                        }
                    }
                    
                    // If it's not a directory, rename the file.
                    else if ([[file stringByDeletingPathExtension] isEqualToString:alertView.accessibilityIdentifier]) {
                        error = nil;
                        
                        if ([fm fileExistsAtPath:newFile]) {
                            [fm removeItemAtPath:newFile error:&error]; // Removes an existing file if it is in the way.
                            
                            if (checkError(error)) {
                                return;
                            }
                        }
                        
                        [fm moveItemAtPath:fullPath toPath:newFile error:&error];
                        
                        if (checkError(error)) {
                            return;
                        }
                    }
                }
            };
            parseAndRenameInDirectory(documentsDirectoryPath);
            [self scanRomDirectory];
            return;
        }
    }
    else if (alertView.tag == UPDATE_AVAILABLE_TAG) {
        if (buttonIndex == 1) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://github.com/iSkythe/GBA4iOS"]];
        }
    }
    else if(buttonIndex > 0)
	{
		NSFileManager *fileManager = [NSFileManager defaultManager];
		
		// need to delete rom.
		NSError *error = nil;
		if ([fileManager removeItemAtPath:self.deletingRomPath error:&error] && !error) {
			NSLog(@"Successfully delete rom.");
		}
		else {
			NSLog(@"%@. %@.", error, [error userInfo]);
		}
		
		if(buttonIndex == 2)
		{
			// need to delete states.
			NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
			NSString *documentsDirectoryPath = [paths objectAtIndex:0];
            NSString *saveStateDirectory = [documentsDirectoryPath stringByAppendingPathComponent:@"Save States"];
            NSString *romName = [[self.deletingRomPath lastPathComponent] stringByDeletingPathExtension];
            NSString *romSaveStateDirectory = [saveStateDirectory stringByAppendingPathComponent:romName];
			
			NSError *error = nil;
            if ([fileManager removeItemAtPath:romSaveStateDirectory error:&error] && !error) {
                NSLog(@"Successfully delete states.");
            }
            else {
                NSLog(@"%@. %@.", error, [error userInfo]);
            }
            
            NSString *saveFilePath = [[self.deletingRomPath stringByDeletingPathExtension] stringByAppendingString:@".sav"];
            
            if ([fileManager removeItemAtPath:saveFilePath error:&error] && !error) {
                NSLog(@"Successfully deleted save file.");
            }
            else {
                NSLog(@"%@. %@.", error, [error userInfo]);
            }
		}
		
		[self scanRomDirectory];
	}
}

#pragma mark - Checking For Updates

- (void)checkForUpdates {
    NSDate *lastCheckForUpdates= [[NSUserDefaults standardUserDefaults] objectForKey:@"lastCheckForUpdates"];
    NSInteger daysSinceLastCheckForUpdate = 0;
    
    if (lastCheckForUpdates) {
        daysSinceLastCheckForUpdate = [self numberOfDaysBetween:lastCheckForUpdates and:[NSDate date]];
    }
    
    if (lastCheckForUpdates && daysSinceLastCheckForUpdate < 3) {
        return;
    }
    
    PFQuery *query = [PFQuery queryWithClassName:@"Updates"];
    [query orderByDescending:@"createdAt"];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        
        NSString *lastUpdateID = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastUpdateID"];
        NSString *updateID = [object objectId];
        
        if ([lastUpdateID isEqualToString:updateID]) {
            return;
        }
        
        if (self.presentedViewController != nil && ![self.presentedViewController isKindOfClass:[GBASettingsViewController class]]) {
            // Only show alert if not playing a game
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *title = [NSString stringWithFormat:@"GBA4iOS Version %@ Available", [object objectForKey:@"version"]];
            NSString *message = [NSString stringWithFormat:@"New in this version:\n\n%@", [object objectForKey:@"releaseNotes"]];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Github", nil];
            alert.tag = UPDATE_AVAILABLE_TAG;
            [alert show];
        });
        
        [[NSUserDefaults standardUserDefaults] setObject:updateID forKey:@"lastUpdateID"];
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"lastCheckForUpdates"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }];
}

- (NSInteger)numberOfDaysBetween:(NSDate *)date1 and:(NSDate *)date2 {
    NSUInteger unitFlags = NSDayCalendarUnit;
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [calendar components:unitFlags fromDate:date1 toDate:date2 options:0];
    return [components day];
}

#pragma mark - UIStoryboard

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSString *rom = [self romPathAtIndexPath:indexPath];
        [[segue destinationViewController] setDetailItem:rom];
    }
}

@end
