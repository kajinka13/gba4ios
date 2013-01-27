//
//  GBCEmulatorViewController.m
//  GBA4iOS
//
//  Created by Riley Testut on 1/3/13.
//  Copyright (c) 2013 Testut Tech. All rights reserved.
//

#import "GBCEmulatorViewController.h"
#import "GBCScreenViewController.h"

#include <pthread.h>

@interface GBCEmulatorViewController () {
    pthread_t gbc_emulation_tid;
}

@property (nonatomic, strong) GBCScreenViewController *screenViewController;
@property (nonatomic, strong) GBCControllerViewController *controllerViewController;

@end

@implementation GBCEmulatorViewController

extern char *__fileName;
extern int __emulation_run;
extern void *app_Thread_Start(void *args);

- (id)initWithROMFilepath:(NSString *)filepath
{
    self = [super init];
    if (self) {
        // Custom initialization
        _romFilepath = filepath;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    CGFloat yOffset = 44.0f * ([UIScreen mainScreen].bounds.size.height == 568);
    
    self.screenViewController = [[GBCScreenViewController alloc] init];
    self.screenViewController.view.frame = CGRectMake(0, 0 + yOffset, 320, 240);
    [self addChildViewController:self.screenViewController];
    [self.view addSubview:self.screenViewController.view];
        
    self.controllerViewController = [[GBCControllerViewController alloc] init];
    self.controllerViewController.delegate = self;
    self.controllerViewController.view.frame = CGRectMake(0, 0, 320, [UIScreen mainScreen].bounds.size.height);
    [self addChildViewController:self.controllerViewController];
    [self.view addSubview:self.controllerViewController.view];
        
    [self startROM];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - Emulation 

- (void)startROM {
    char cFileName[256];
    
    strlcpy(cFileName, [self.romFilepath cStringUsingEncoding: NSASCIIStringEncoding ], sizeof(cFileName));
    
    __fileName = strdup(cFileName);
    
    DLog(@"Starting Emulation");
    
    __emulation_run = 1;
    pthread_create(&gbc_emulation_tid, NULL, app_Thread_Start, NULL);
    LOGDEBUG("MainView.startEmulator(): Done");
}

#pragma mark - Controller Delegate

- (void)controllerDidPauseROM:(GBCControllerViewController *)controller {
    NSLog(@"Pause");
}

@end
