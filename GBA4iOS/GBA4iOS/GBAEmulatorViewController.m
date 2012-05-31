//
//  GBAEmulatorViewController.m
//  GBA4iOS
//
//  Created by Riley Testut on 5/29/12.
//  Copyright (c) 2012 Testut Tech. All rights reserved.
//

#import "GBAEmulatorViewController.h"

char __savefileName[512];
char __lastfileName[512];
char *__fileName;
int __mute;
extern int __emulation_run;
extern char __fileNameTempSave[512];

extern void *gpSPhone_Thread_Start(void *args);

float __audioVolume = 1.0;

@interface GBAEmulatorViewController ()

@end

@implementation GBAEmulatorViewController
@synthesize romPath;
@synthesize screenView;
@synthesize controllerViewController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.screenView = [[ScreenView alloc] initWithFrame:CGRectMake(0, 0, 320, 240)];
    self.screenView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.screenView];
    
    self.controllerViewController= [[GBAControllerViewController alloc] init];
    self.controllerViewController.view.frame = CGRectMake(0, 0, 320, 480);
    [self.view addSubview:self.controllerViewController.view];
    
	// Do any additional setup after loading the view.
}

- (void)loadROM:(NSString *)romFilePath {
    __emulation_run = 1;
    
    char cFileName[256];
    
    strlcpy(cFileName, [ romFilePath cStringUsingEncoding: NSASCIIStringEncoding], sizeof(cFileName));
        
    __fileName = strdup((char *)[romFilePath UTF8String]);
        
    pthread_create(&emulation_tid, NULL, gpSPhone_Thread_Start, NULL);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
