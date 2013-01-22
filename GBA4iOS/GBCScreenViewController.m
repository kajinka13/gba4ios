//
//  GBCScreenViewController.m
//  GBA4iOS
//
//  Created by Riley Testut on 1/3/13.
//  Copyright (c) 2013 Testut Tech. All rights reserved.
//

#import "GBCScreenViewController.h"

#import "ScreenViewGameBoyColor.h"

@interface GBCScreenViewController ()

@property (nonatomic, strong) ScreenViewGameBoyColor *screenView;

@end

@implementation GBCScreenViewController

- (id)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.screenView = [[ScreenViewGameBoyColor alloc] initWithFrame:CGRectMake(0, 0, 320, 240)];
    [self.view addSubview:self.screenView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
