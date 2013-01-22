//
//  GBCControllerViewController.h
//  GBA4iOS
//
//  Created by Ethan Mick on 12/28/12.
//  Copyright (c) 2012 Testut Tech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GraphicsServices.h"
#import <UIKit/UIKit.h>
#import "UIView-Geometry.h"
#import "ScreenViewGameBoyColor.h"
#import "app_iPhone.h"

@class GBCControllerViewController;

@protocol GBCControllerDelegate <NSObject>

- (void)controllerDidPauseROM:(GBCControllerViewController *)controller;

@end

@interface GBCControllerViewController : UIViewController {
    int screenOrientation;
    BOOL fixedRects;
    
    CGRect ButtonA;
    CGRect ButtonB;
    CGRect ButtonAB;
    CGRect Up;
    CGRect Left;
    CGRect Down;
    CGRect Right;
    CGRect UpLeft;
    CGRect DownLeft;
    CGRect UpRight;
    CGRect DownRight;
    CGRect Start;
	CGRect Select;
    CGRect LPad;
    CGRect RPad;
    CGRect Menu;
    CGRect notifyUpdateRect;
    
    int orientation;
}

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic) BOOL readyToSustain;
@property (strong, nonatomic) NSMutableSet *sustainedButtons;

@property (nonatomic, weak) id<GBCControllerDelegate> delegate;


- (UIImage *)getControllerImage;
- (void)getControllerCoords;

@end
