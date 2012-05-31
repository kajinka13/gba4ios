//
//  GBAMasterViewController.m
//  GBA4iOS
//
//  Created by Riley Testut on 5/23/12.
//  Copyright (c) 2012 Testut Tech. All rights reserved.
//

#import "GBAMasterViewController.h"

#import "GBADetailViewController.h"

@interface GBAMasterViewController ()
@property (strong, nonatomic) NSMutableDictionary *romDictionary;
@property (strong, nonatomic) NSArray *romSections;
@property (nonatomic) NSInteger currentSection_;
@end

@implementation GBAMasterViewController

@synthesize detailViewController = _detailViewController;
@synthesize romDictionary;
@synthesize romSections;
@synthesize currentSection_;
@synthesize currentRomPath;

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
	// Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    [self scanRomDirectory];

    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    self.navigationItem.rightBarButtonItem = addButton;
    self.detailViewController = (GBADetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self scanRomDirectory];
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

#pragma mark -
#pragma mark ROM loading methods

- (void)scanRomDirectory {
    
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
        if ([filename hasSuffix:@".zip"] || [filename hasSuffix:@".ZIP"] || [filename hasSuffix:@".gba"] || [filename hasSuffix:@".GBA"]) { 
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
}

- (void) checkForSav {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *savDirectory = [documentsDirectory stringByAppendingPathComponent:@"sav"];
    
    [fileManager createDirectoryAtURL:[NSURL fileURLWithPath:savDirectory] withIntermediateDirectories:YES attributes:nil error:nil];
    //Recommended practice to always attempt to make the folder. Will return if it already exists.
    
    NSArray* dirContents = [fileManager contentsOfDirectoryAtPath:documentsDirectory error:nil];
    [dirContents enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *filename = obj;
        if ([filename hasSuffix:@"sav"]) {
            NSError *error = nil;
            NSString *originalFilePath = [documentsDirectory stringByAppendingPathComponent:filename];
            NSString *destinaionFilePath = [savDirectory stringByAppendingPathComponent:filename];
            if ([fileManager copyItemAtPath:originalFilePath toPath:destinaionFilePath error:&error] && !error) {
                [fileManager removeItemAtPath:originalFilePath error:nil];
                NSLog(@"Successfully copied sav file to sav directory");
            }
            else {
                NSLog(@"%@. %@.", error, [error userInfo]);
            }
        }
    }];
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
    cell.textLabel.text = filename;
    
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
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSString *rom = [self romPathAtIndexPath:indexPath];
        [[segue destinationViewController] setDetailItem:rom];
    }
    else if ([[segue identifier] isEqualToString:@"loadROM"]) {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectoryPath = [paths objectAtIndex:0];
            
            UITableViewCell *cell = (UITableViewCell *)sender;
            self.currentRomPath = [documentsDirectoryPath stringByAppendingPathComponent:[self romPathAtIndexPath:[self.tableView indexPathForCell:cell]]];
            
            [UIApplication sharedApplication].statusBarHidden = YES;
            GBAEmulatorViewController *emulatorViewController = [segue destinationViewController];
            emulatorViewController.wantsFullScreenLayout = YES;
            emulatorViewController.romPath = self.currentRomPath;
        }
        
    }
}

@end
