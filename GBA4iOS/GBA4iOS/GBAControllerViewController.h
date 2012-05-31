//
//  GBAControllerViewController.h
//  GBAController
//
//  Created by Riley Testut on 5/29/10.
//  Copyright Riley Testut 2010. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "../../iGBA/Frameworks/GraphicsServices.h"
#import <UIKit/UIKit.h>
#import "../../iGBA/Frameworks/UIKit-Private/UIView-Geometry.h"
#import "ScreenView.h"

@interface GBAControllerViewController : UIViewController <UIAlertViewDelegate> {
    UIImage *controllerImage;
	UIImageView *imageView;
	UIButton *infoButton;
	UIButton *connectionButton;
	
	CGRect Up;
    CGRect Left;
    CGRect Down;
    CGRect Right;
    CGRect UpLeft;
    CGRect DownLeft;
    CGRect UpRight;
    CGRect DownRight;
    CGRect Select;
    CGRect Start;
    CGRect B;
    CGRect A;
    CGRect AB;
    CGRect LPad;
    CGRect RPad;
    CGRect Menu;
	
}

@property (strong, nonatomic) UIImage *controllerImage;
@property (nonatomic, strong) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) IBOutlet UIButton *infoButton;
@property (nonatomic, strong) IBOutlet UIButton *connectionButton;
@property (copy, nonatomic) NSString *imageName;
@property (strong, nonatomic) NSMutableSet *sustainedButtons;
#if APP_BUILD
@property (weak, nonatomic) IBOutlet UIButton *sustainButton;//This errors out when compiling emulator
#else 
@property (retain, nonatomic) IBOutlet UIButton *sustainButton;
#endif
@property (nonatomic) BOOL readyToSustain;

- (void) getControllerCoords;
- (IBAction)sustain:(id)sender;
- (UIImage *)getControllerImage;


@end

