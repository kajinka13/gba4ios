//
//  GBAEmulatorViewController.m
//  GBA4iOS
//
//  Created by Riley Testut on 5/29/12.
//  Copyright (c) 2012 Testut Tech. All rights reserved.
//

#import "GBAEmulatorViewController.h"
#import "GBASettingsManager.h"

#include <sys/sysctl.h>

char __savefileName[512];
char __lastfileName[512];
char *__fileName;
int __mute;
extern int __emulation_run;
extern char __fileNameTempSave[512];

extern void *gpSPhone_Thread_Start(void *args);
extern void gpSPhone_Halt();

extern void save_game_state(char *filepath);
extern void load_game_state(char *filepath);
extern volatile int __emulation_paused;
extern char *savestate_directory;

extern int use_fastest_speed;

float __audioVolume = 1.0;

static GBAEmulatorViewController *emulatorViewController;

@interface GBAEmulatorViewController () {
    UIDeviceOrientation currentDeviceOrientation_;
    
    CFAbsoluteTime _romStartTime;
    CFAbsoluteTime _romPauseTime;
}

@property (copy, nonatomic) NSString *romSaveStateDirectory;

@end

#define RADIANS(degrees) ((degrees * M_PI) / 180.0)
#define DEGREES(radians) (radians * 180.0/M_PI)

@implementation GBAEmulatorViewController
@synthesize romPath;
@synthesize screenView;
@synthesize controllerViewController;
@synthesize saveStateArray;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        emulatorViewController = self;
        NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    use_fastest_speed = 0;
    
    self.view.backgroundColor = [UIColor blackColor];
    
    self.screenView = [[ScreenView alloc] initWithFrame:CGRectMake(0, 0, 320, 240)];
    self.screenView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.screenView];
    
    self.controllerViewController= [[GBAControllerViewController alloc] init];
    self.controllerViewController.view.frame = [UIScreen mainScreen].bounds;
    self.controllerViewController.emulatorViewController = self;
    [self.view addSubview:self.controllerViewController.view];
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];	//Keep in this method
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRotate:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
	// Do any additional setup after loading the view.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)loadROM:(NSString *)romFilePath {
    __emulation_run = 1;
    
    char cFileName[256];
    
    strlcpy(cFileName, [ romFilePath cStringUsingEncoding: NSUTF8StringEncoding], sizeof(cFileName));
        
    __fileName = strdup((char *)[romFilePath UTF8String]);
    
    _romStartTime = CFAbsoluteTimeGetCurrent();
        
    pthread_create(&emulation_tid, NULL, gpSPhone_Thread_Start, NULL);
}

- (void)quitROM {
    
    if ([GBASettingsManager sharedManager].autoSave) {
        [self autosaveSaveState];
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        gpSPhone_Halt();
        pthread_join(emulation_tid, NULL);
    });
    [UIApplication sharedApplication].statusBarHidden = NO;
    [[self presentingViewController] dismissModalViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.presentingViewController.interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        [self rotateToDeviceOrientation:UIDeviceOrientationLandscapeLeft];
    }
    else if (self.presentingViewController.interfaceOrientation == UIInterfaceOrientationLandscapeLeft) {
        [self rotateToDeviceOrientation:UIDeviceOrientationLandscapeRight];
    }
        
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (__emulation_run == 0) {
        [self loadROM:self.romPath];
    }
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

#pragma mark Rotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

- (void)didRotate:(NSNotification *)notification {
    [self rotateToDeviceOrientation:[[UIDevice currentDevice] orientation]];
}

- (void)rotateToDeviceOrientation:(UIDeviceOrientation)deviceOrientation {    
    if (deviceOrientation == UIDeviceOrientationFaceUp || deviceOrientation == UIDeviceOrientationFaceDown || deviceOrientation == UIDeviceOrientationPortraitUpsideDown || deviceOrientation == UIDeviceOrientationUnknown) {
        return;
    }
    
    if (currentDeviceOrientation_ != deviceOrientation) {
        currentDeviceOrientation_ = deviceOrientation;
        
        if (deviceOrientation == UIDeviceOrientationLandscapeLeft) {
            self.controllerViewController.landscape = YES;
            self.controllerViewController.imageView.frame = [UIScreen mainScreen].bounds;
            self.controllerViewController.view.transform = CGAffineTransformMakeRotation(RADIANS(0.0));
            [UIApplication sharedApplication].statusBarOrientation = UIInterfaceOrientationLandscapeRight;
        }
        else if (deviceOrientation == UIDeviceOrientationLandscapeRight) {
            self.controllerViewController.landscape = YES;
            self.controllerViewController.imageView.frame = [UIScreen mainScreen].bounds;
            self.controllerViewController.view.transform = CGAffineTransformMakeRotation(RADIANS(180.0));
            [UIApplication sharedApplication].statusBarOrientation = UIInterfaceOrientationLandscapeLeft;
        }
        else if (deviceOrientation == UIDeviceOrientationPortrait) {
            
            CGFloat yOffset = 240 + (88 * ([UIScreen mainScreen].bounds.size.height == 568));
            
            self.controllerViewController.landscape = NO;
            self.controllerViewController.imageView.frame = CGRectMake(0, yOffset, 320, 240);
            self.controllerViewController.view.transform = CGAffineTransformMakeRotation(RADIANS(0.0));
            [UIApplication sharedApplication].statusBarOrientation = UIInterfaceOrientationPortrait;
        }
        [self.screenView rotateForDeviceOrientation:deviceOrientation];
        [self.controllerViewController updateUI];
    }
}

#pragma mark Pause Menu

- (NSString *)romSaveStateDirectory {
    if (_romSaveStateDirectory) {
        return _romSaveStateDirectory;
    }
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectoryPath = [paths objectAtIndex:0];
    NSString *saveStateDirectory = [documentsDirectoryPath stringByAppendingPathComponent:@"Save States"];
    NSString *romName = [[self.romPath lastPathComponent] stringByDeletingPathExtension];
    _romSaveStateDirectory = [[saveStateDirectory stringByAppendingPathComponent:romName] copy];
    
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    [fileManager createDirectoryAtPath:self.romSaveStateDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    
    return _romSaveStateDirectory;
}

unsigned int numberOfCPUCores()
{
    size_t len;
    unsigned int ncpu;
    
    len = sizeof(ncpu);
    sysctlbyname ("hw.ncpu",&ncpu,&len,NULL,0);
    
    return ncpu;
}

- (BOOL)deviceSupportsMaximumSpeed {
    return (numberOfCPUCores() > 1);
}

- (void)pauseMenu {
    _romPauseTime = CFAbsoluteTimeGetCurrent();
    __emulation_paused = 1;
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Paused", @"") delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    
    if ([self deviceSupportsMaximumSpeed]) {
        [actionSheet addButtonWithTitle:NSLocalizedString(@"Toggle Speed", @"")];
    }
    [actionSheet addButtonWithTitle:NSLocalizedString(@"Save State", @"")];
    [actionSheet addButtonWithTitle:NSLocalizedString(@"Load State", @"")];
    [actionSheet addButtonWithTitle:NSLocalizedString(@"Quit Game", @"")];
    [actionSheet addButtonWithTitle:NSLocalizedString(@"Cancel", @"")];
    
    [actionSheet setCancelButtonIndex:actionSheet.numberOfButtons - 1];
    [actionSheet setDestructiveButtonIndex:actionSheet.numberOfButtons - 2];
    actionSheet.tag = 3;
    [actionSheet showInView:self.controllerViewController.view];
}

- (void)showActionSheetWithTag:(NSInteger)tag {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSString *saveStateInfoPath = [self.romSaveStateDirectory stringByAppendingPathComponent:@"info.plist"];
        
        if (!self.saveStateArray) {
            self.saveStateArray = [[NSMutableArray alloc] initWithContentsOfFile:saveStateInfoPath];
        }
        if ([self.saveStateArray count] == 0) {
            self.saveStateArray = [[NSMutableArray alloc] initWithCapacity:5];
            
            for (int i = 0; i < 5; i++) {
                [self.saveStateArray addObject:NSLocalizedString(@"Empty", @"")];
            }
            [self.saveStateArray writeToFile:saveStateInfoPath atomically:YES];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Select Save State", @"") delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
            
            if (tag == 2 && [GBASettingsManager sharedManager].autoSave) {
                [actionSheet addButtonWithTitle:NSLocalizedString(@"Last Autosave", @"")];
            }
            [actionSheet addButtonWithTitle:[self.saveStateArray objectAtIndex:0]];
            [actionSheet addButtonWithTitle:[self.saveStateArray objectAtIndex:1]];
            [actionSheet addButtonWithTitle:[self.saveStateArray objectAtIndex:2]];
            [actionSheet addButtonWithTitle:[self.saveStateArray objectAtIndex:3]];
            [actionSheet addButtonWithTitle:[self.saveStateArray objectAtIndex:4]];
            [actionSheet addButtonWithTitle:NSLocalizedString(@"Cancel", @"")];
            [actionSheet setCancelButtonIndex:actionSheet.numberOfButtons - 1];
            actionSheet.tag = tag;
            [actionSheet showInView:self.view];
        });
    });
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == 3) {
        return [self pauseMenuClickedButtonAtIndex:buttonIndex];
    }
    
    NSString *saveStateInfoPath = [self.romSaveStateDirectory stringByAppendingPathComponent:@"info.plist"];
    
    if (actionSheet.tag == 2 && [GBASettingsManager sharedManager].autoSave) {
        buttonIndex--;
    }
    
    NSString *filepath = [self.romSaveStateDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%d.svs", buttonIndex]];
    
    if (buttonIndex == -1) {
        filepath = [self.romSaveStateDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"autosave.svs"]];
    }
    
    char *saveStateFilepath = strdup((char *)[filepath UTF8String]);
    
    if (actionSheet.tag == 1 && buttonIndex != 5) {
        NSMutableDictionary* dictionary = [[NSThread currentThread] threadDictionary];
        NSDateFormatter* dateFormatter = [dictionary objectForKey:@"dateFormatterShortStyleDate"];
        if (dateFormatter == nil) {
            dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateStyle:NSDateFormatterShortStyle];
            [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
            [dictionary setObject:dateFormatter forKey:@"dateFormatterShortStyleDate"];
        }
        
        NSString *title = [dateFormatter stringFromDate:[NSDate date]];
        
        [self.saveStateArray replaceObjectAtIndex:buttonIndex withObject:title];
                
        save_game_state(saveStateFilepath);
        
        [self.saveStateArray writeToFile:saveStateInfoPath atomically:YES];
    }
    else if (actionSheet.tag == 2 && buttonIndex != 5) {
        
        if ([GBASettingsManager sharedManager].autoSave) {
            if (buttonIndex >= 0) {
                [self autosaveSaveState];
            }
            else {
                NSString *backupFilepath = [self.romSaveStateDirectory stringByAppendingPathComponent:@"backup.svs"];
                if (_romPauseTime - _romStartTime >= 3.0f) {
                    [self saveStateToPath:backupFilepath];
                }
            }
        }
        
        load_game_state(saveStateFilepath);
        
        if ([GBASettingsManager sharedManager].autoSave) {
            if (buttonIndex < 0) {
                NSString *backupFilepath = [self.romSaveStateDirectory stringByAppendingPathComponent:@"backup.svs"];
                
                NSFileManager *fileManager = [[NSFileManager alloc] init];
                [fileManager removeItemAtPath:filepath error:NULL];
                [fileManager moveItemAtPath:backupFilepath toPath:filepath error:NULL];
            }
        }
        
        
    }
     __emulation_paused = 0;
}

- (void)pauseMenuClickedButtonAtIndex:(NSInteger)buttonIndex {
    if (![self deviceSupportsMaximumSpeed]) {
        buttonIndex++;
    }
    
    switch (buttonIndex) {
        case 0:
            
            if (use_fastest_speed == 0) {
                use_fastest_speed = 1;
            }
            else {
                use_fastest_speed = 0;
            }
            
            __emulation_paused = 0;
            
            break;
            
            
        case 1:
            [self showActionSheetWithTag:1];
            //save_game_state();
            break;
            
        case 2:
            [self showActionSheetWithTag:2];
            //load_game_state();
            break;
            
        case 3:
            __emulation_paused = 0;
            [self quitROM];
            break;
            
        default:
            __emulation_paused = 0;
            break;
    }
}

void uncaughtExceptionHandler(NSException *exception) {
    if ([GBASettingsManager sharedManager].autoSave) {
        [emulatorViewController autosaveSaveState];
    }
}

- (void)didEnterBackground:(NSNotification *)notification {
    if ([GBASettingsManager sharedManager].autoSave) {
        [emulatorViewController autosaveSaveState];
    }
}

- (void)autosaveSaveState {
    
    if (_romPauseTime - _romStartTime >= 3.0f) {
        // If the user loads a save state in the first 3 seconds, the autosave would probably be useless to them as it would take them back to the title screen of their game
        NSString *filepath = [self.romSaveStateDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"autosave.svs"]];
        [self saveStateToPath:filepath];
    }
}

- (void)saveStateToPath:(NSString *)filepath {
    char *saveStateFilepath = strdup((char *)[filepath UTF8String]);
    
    save_game_state(saveStateFilepath);
}

@end
