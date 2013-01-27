//
//  SNESControllerViewController.m
//  SNESController
//
//  Created by Yusef Napora on 5/5/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "GBAControllerViewController.h"
#import "GBASettingsManager.h"

#import "../iGBA/iphone/gpSPhone/src/gpSPhone_iPhone.h"

#define	DefaultControllerImage @"landscape_controller"

#define RADIANS(degrees) ((degrees * M_PI) / 180.0)

static unsigned long pressedButtons;
static unsigned long newtouches[10];
static unsigned long oldtouches[10];

extern void reset_sound();
extern void sound_exit();
extern void init_sound();

enum  { GP2X_UP=0x1,       GP2X_LEFT=0x4,       GP2X_DOWN=0x10,  GP2X_RIGHT=0x40,
	GP2X_START=1<<8,   GP2X_SELECT=1<<9,    GP2X_L=1<<10,    GP2X_R=1<<11,
	GP2X_A=1<<12,      GP2X_B=1<<13,        GP2X_X=1<<14,    GP2X_Y=1<<15,
	GP2X_VOL_UP=1<<23, GP2X_VOL_DOWN=1<<22, GP2X_PUSH=1<<27 };

void rt_dispatch_sync_on_main_thread(dispatch_block_t block) {
    if ([NSThread isMainThread]) {
        block();
    } else {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}

@implementation GBAControllerViewController
@synthesize imageView;
@synthesize infoButton;
@synthesize connectionButton;
@synthesize imageName;
@synthesize sustainedButtons;
@synthesize sustainButton;
@synthesize readyToSustain;
@synthesize controllerImage;
@synthesize landscape;
@synthesize emulatorViewController;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	self.infoButton.transform = CGAffineTransformRotate(CGAffineTransformIdentity, RADIANS(0.0));
    self.connectionButton.transform = CGAffineTransformRotate(CGAffineTransformIdentity, RADIANS(0.0));
	self.view.multipleTouchEnabled = YES;
    self.sustainedButtons = [NSMutableSet setWithCapacity:12];//
    
    CGFloat yOffset = 240 + (88 * ([UIScreen mainScreen].bounds.size.height == 568));
    
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, yOffset, 320, 240)];
    [self.view addSubview:self.imageView];
    self.imageView.image = [self getControllerImage];
    [self getControllerCoords];
    
}

- (void)updateUI {
    self.imageView.image = [self getControllerImage];
    [self getControllerCoords];
}

#pragma mark - Background Image

- (UIImage *)getControllerImage {
    NSString *controllerFilename;
    UIImage *image;
    
    if(self.landscape)
    {
        if ([UIScreen mainScreen].bounds.size.height == 568) {
            controllerFilename = [ NSString stringWithFormat:@"controller_fs%d-568h.png", [GBASettingsManager sharedManager].landscapeSkin];
        }
	    else {
           controllerFilename = [ NSString stringWithFormat:@"controller_fs%d.png", [GBASettingsManager sharedManager].landscapeSkin ];
        }
        if ([GBASettingsManager sharedManager].landscapeSkin == 1) {
            self.imageView.alpha = 0.50f;
        }
        else {
            self.imageView.alpha = 1.0f;
        }
	}
	else
	{
	    controllerFilename = [ NSString stringWithFormat:@"controller_hs%d.png", [GBASettingsManager sharedManager].portraitSkin ];
        self.imageView.alpha = 1.0f;
	}
    
    LOGDEBUG("ControllerView.getControllerImage(): Loading controller image %s",
             [ controllerFilename cStringUsingEncoding: NSASCIIStringEncoding ]);
    image = [ UIImage imageNamed:controllerFilename];
    return image;
};

- (void) changeBackgroundImage:(NSString *)newImageName {
    self.imageName = newImageName;
    rt_dispatch_sync_on_main_thread(^{
        self.imageView.image = [UIImage imageNamed:self.imageName];
    });
    [self getControllerCoords];
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [self setSustainButton:nil];
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (IBAction)sustain:(id)sender {
    self.readyToSustain = !self.readyToSustain;
    UIButton *button = (UIButton *)sender;
    
    if (self.readyToSustain) {
        [button setImage:[UIImage imageNamed:@"sustainButtonHighlighted"] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"sustainButton"] forState:UIControlStateHighlighted];
    }
    else {
        [button setImage:[UIImage imageNamed:@"sustainButton"] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"sustainButtonHighlighted"] forState:UIControlStateHighlighted];
    }
}

#define MyCGRectContainsPoint(rect, point)						  \
(((point.x >= rect.origin.x) &&								        \
(point.y >= rect.origin.y) &&							          \
(point.x <= rect.origin.x + rect.size.width) &&			\
(point.y <= rect.origin.y + rect.size.height)) ? 1 : 0)


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{	    
	int touchstate[10];
	//Get all the touches.
	int i;
	NSSet *allTouches = [event allTouches];
	int touchcount = [allTouches count];
    
    if (self.readyToSustain) {
        pressedButtons = 0;
        [self.sustainedButtons removeAllObjects];
    }
	
	for (i = 0; i < 10; i++) 
	{
		touchstate[i] = 0;
		oldtouches[i] = newtouches[i];
	}
    
	
	for (i = 0; i < touchcount; i++) 
	{
		UITouch *touch = [[allTouches allObjects] objectAtIndex:i];
		
		if( touch != nil && 
		   ( touch.phase == UITouchPhaseBegan ||
			touch.phase == UITouchPhaseMoved ||
			touch.phase == UITouchPhaseStationary) )
		{
			struct CGPoint point;
			point = [touch locationInView:self.view];
            
            /*if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeLeft) {
                point = CGPointMake(480 - point.x, point.y);//Fixes offset touches due to the transformation of the controller
            }*/
            
			touchstate[i] = 1;
            		
			if (MyCGRectContainsPoint(Left, point)) 
			{
				pressedButtons |= BIT_L;
				newtouches[i] = BIT_L;
                if (self.readyToSustain) {
                    [self.sustainedButtons addObject:[NSNumber numberWithUnsignedInt:BIT_L]];
                }
			}
			else if (MyCGRectContainsPoint(Right, point)) 
			{
				pressedButtons |= BIT_R;
				newtouches[i] = BIT_R;
                if (self.readyToSustain) {
                    [self.sustainedButtons addObject:[NSNumber numberWithUnsignedInt:BIT_R]];
                }
			}
			else if (MyCGRectContainsPoint(Up, point)) 
			{
				pressedButtons |= BIT_U;
				newtouches[i] = BIT_U;
                if (self.readyToSustain) {
                    [self.sustainedButtons addObject:[NSNumber numberWithUnsignedInt:BIT_U]];
                }
			}
			else if (MyCGRectContainsPoint(Down, point))
			{
				pressedButtons |= BIT_D;
				newtouches[i] = BIT_D;
                if (self.readyToSustain) {
                    [self.sustainedButtons addObject:[NSNumber numberWithUnsignedInt:BIT_D]];
                }
			}
			else if (MyCGRectContainsPoint(UpLeft, point)) 
			{
				pressedButtons |= BIT_U | BIT_L;
				newtouches[i] = BIT_U | BIT_L;
                if (self.readyToSustain) {
                    [self.sustainedButtons addObject:[NSNumber numberWithUnsignedInt:BIT_U]];
                    [self.sustainedButtons addObject:[NSNumber numberWithUnsignedInt:BIT_L]];
                }
			} 
			else if (MyCGRectContainsPoint(DownLeft, point)) 
			{
				pressedButtons |= BIT_D | BIT_L;
				newtouches[i] = BIT_D | BIT_L;
                if (self.readyToSustain) {
                    [self.sustainedButtons addObject:[NSNumber numberWithUnsignedInt:BIT_D]];
                    [self.sustainedButtons addObject:[NSNumber numberWithUnsignedInt:BIT_L]];
                }
			}
			else if (MyCGRectContainsPoint(UpRight, point)) 
			{
				pressedButtons |= BIT_U | BIT_R;
				newtouches[i] = BIT_U | BIT_R;
                if (self.readyToSustain) {
                    [self.sustainedButtons addObject:[NSNumber numberWithUnsignedInt:BIT_U]];
                    [self.sustainedButtons addObject:[NSNumber numberWithUnsignedInt:BIT_R]];
                }
			}
			else if (MyCGRectContainsPoint(DownRight, point)) 
			{
				pressedButtons |= BIT_D | BIT_R;
				newtouches[i] = BIT_D | BIT_R;
                if (self.readyToSustain) {
                    [self.sustainedButtons addObject:[NSNumber numberWithUnsignedInt:BIT_D]];
                    [self.sustainedButtons addObject:[NSNumber numberWithUnsignedInt:BIT_R]];
                }
			}	
            else if (MyCGRectContainsPoint(A, point)) 
			{
				pressedButtons |= BIT_A;
				newtouches[i] = BIT_A;
                if (self.readyToSustain) {
                    [self.sustainedButtons addObject:[NSNumber numberWithUnsignedInt:BIT_A]];
                }
			}
            else if (MyCGRectContainsPoint(B, point)) 
			{
				pressedButtons |= BIT_B;
				newtouches[i] = BIT_B;
                if (self.readyToSustain) {
                    [self.sustainedButtons addObject:[NSNumber numberWithUnsignedInt:BIT_B]];
                }
			}
            else if (MyCGRectContainsPoint(AB, point)) 
			{
				pressedButtons |= BIT_A | BIT_B;
				newtouches[i] = BIT_A | BIT_B;
                if (self.readyToSustain) {
                    [self.sustainedButtons addObject:[NSNumber numberWithUnsignedInt:BIT_A]];
                    [self.sustainedButtons addObject:[NSNumber numberWithUnsignedInt:BIT_B]];
                }
			}
			else if (MyCGRectContainsPoint(LPad, point)) 
			{
				pressedButtons |= BIT_LPAD;
				newtouches[i] = BIT_LPAD;
                if (self.readyToSustain) {
                    [self.sustainedButtons addObject:[NSNumber numberWithUnsignedInt:BIT_LPAD]];
                    [self.sustainedButtons addObject:[NSNumber numberWithUnsignedInt:BIT_LPAD]];
                }
			}
			else if (MyCGRectContainsPoint(RPad, point)) 
			{
				pressedButtons |= BIT_RPAD;
				newtouches[i] = BIT_RPAD;
                if (self.readyToSustain) {
                    [self.sustainedButtons addObject:[NSNumber numberWithUnsignedInt:BIT_RPAD]];
                    [self.sustainedButtons addObject:[NSNumber numberWithUnsignedInt:BIT_RPAD]];
                }
			}			
			else if (MyCGRectContainsPoint(Select, point)) 
			{
				pressedButtons |= BIT_SEL;
				newtouches[i] = BIT_SEL;
                if (self.readyToSustain) {
                    [self.sustainedButtons addObject:[NSNumber numberWithUnsignedInt:BIT_SEL]];
                }
			}
			else if (MyCGRectContainsPoint(Start, point)) 
			{
				pressedButtons |= BIT_ST;
				newtouches[i] = BIT_ST;
                if (self.readyToSustain) {
                    [self.sustainedButtons addObject:[NSNumber numberWithUnsignedInt:BIT_ST]];
                }
			}
			else if (MyCGRectContainsPoint(Menu, point)) 
			{
                [emulatorViewController pauseMenu];
			}
			
			if(oldtouches[i] != newtouches[i])
			{
				pressedButtons &= ~(oldtouches[i]);
			}
		}
	} 
    
	for (i = 0; i < 10; i++) 
	{
		if(touchstate[i] == 0)
		{
			pressedButtons &= ~(newtouches[i]);
			newtouches[i] = 0;
			oldtouches[i] = 0;
		}
	}
    
    if (!self.readyToSustain) {//This way it doesn't re-add the objects when sustaining the button
        NSArray *objects = [self.sustainedButtons allObjects];
        for (int i = 0; i < objects.count; i++) {
            pressedButtons |= [[objects objectAtIndex:i] unsignedIntValue];
        }
    }
    else {
        self.readyToSustain = NO;
        [self.sustainButton setImage:[UIImage imageNamed:@"sustainButton"] forState:UIControlStateNormal];
        [self.sustainButton setImage:[UIImage imageNamed:@"sustainButtonHighlighted"] forState:UIControlStateHighlighted];
    }
    
    cPad1 = pressedButtons;
    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	[self touchesBegan:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	[self touchesBegan:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	[self touchesBegan:touches withEvent:event];
}


- (void)getControllerCoords {
    char string[256];
    char cFileName[256];
    FILE *fp;
    NSString *file;
    
    if(landscape)
    {
        if ([UIScreen mainScreen].bounds.size.height == 568) {
            file = [ NSString stringWithFormat:@"controller_fs%d-568h.txt", [GBASettingsManager sharedManager].landscapeSkin];
        }
        else {
            file = [ NSString stringWithFormat:@"controller_fs%d.txt", [GBASettingsManager sharedManager].landscapeSkin];
        }
	}
	else
	{
	    file = [ NSString stringWithFormat:@"controller_hs%d.txt", [GBASettingsManager sharedManager].portraitSkin];
	}
    strlcpy(cFileName,
            [ file cStringUsingEncoding: NSASCIIStringEncoding ],
            sizeof(cFileName));
    
    CGFloat yOffset = 0.0;
    
    if ([UIScreen mainScreen].bounds.size.height == 568 && !landscape) { // The landscape controllers have the new coordinates in the text file.
        yOffset = 88.0f;
    }
    
    fp = fopen(cFileName, "r");
    if (fp) {
        int i = 0;
        while(fgets(string, 256, fp) != NULL && i < 16) {
            char* result = strtok(string, ",");
            int coords[4];
            int i2 = 1;
            while( result != NULL && i2 < 5 )
            {
                coords[i2 - 1] = atoi(result);
                result = strtok(NULL, ",");
                i2++;
            }
            switch(i)
            {
                    
                case 0:    DownLeft   	= CGRectMake( coords[0], coords[1] + yOffset, coords[2], coords[3] ); break;
                case 1:    Down   	= CGRectMake( coords[0], coords[1] + yOffset, coords[2], coords[3] ); break;
                case 2:    DownRight    = CGRectMake( coords[0], coords[1] + yOffset, coords[2], coords[3] ); break;
                case 3:    Left  	= CGRectMake( coords[0], coords[1] + yOffset, coords[2], coords[3] ); break;
                case 4:    Right  	= CGRectMake( coords[0], coords[1] + yOffset, coords[2], coords[3] ); break;
                case 5:    UpLeft     	= CGRectMake( coords[0], coords[1] + yOffset, coords[2], coords[3] ); break;
                case 6:    Up     	= CGRectMake( coords[0], coords[1] + yOffset, coords[2], coords[3] ); break;
                case 7:    UpRight  	= CGRectMake( coords[0], coords[1] + yOffset, coords[2], coords[3] ); break;
                case 8:    Select = CGRectMake( coords[0], coords[1] + yOffset, coords[2], coords[3] ); break;
                case 9:    Start  = CGRectMake( coords[0], coords[1] + yOffset, coords[2], coords[3] ); break;
                case 10:   A      = CGRectMake( coords[0], coords[1] + yOffset, coords[2], coords[3] ); break;
                case 11:   B      = CGRectMake( coords[0], coords[1] + yOffset, coords[2], coords[3] ); break;
                case 12:   AB     = CGRectMake( coords[0], coords[1] + yOffset, coords[2], coords[3] ); break;
                case 13:   LPad   = CGRectMake( coords[0], coords[1] + yOffset, coords[2], coords[3] ); break;
                case 14:   RPad   = CGRectMake( coords[0], coords[1] + yOffset, coords[2], coords[3] ); break;
                case 15:   Menu   = CGRectMake( coords[0], coords[1] + yOffset, coords[2], coords[3] ); break;
            }
           	i++;
        }
        fclose(fp);
    }
    
    //[self showControllerButtons]; //For debugging
}

- (void)showControllerButtons {
    
    for (UIView *view in self.view.subviews) {
        if (view.backgroundColor == [UIColor redColor]) {
            [view removeFromSuperview];
        }
    }
    
    UIView *view1 = [[UIView alloc] initWithFrame:DownLeft];
    view1.backgroundColor = [UIColor redColor];
    view1.alpha = 0.5;
    
    UIView *view2 = [[UIView alloc] initWithFrame:Down];
    view2.backgroundColor = [UIColor redColor];
    view2.alpha = 0.5;
    
    UIView *view3 = [[UIView alloc] initWithFrame:DownRight];
    view3.backgroundColor = [UIColor redColor];
    view3.alpha = 0.5;
    
    UIView *view4 = [[UIView alloc] initWithFrame:Left];
    view4.backgroundColor = [UIColor redColor];
    view4.alpha = 0.5;
    
    UIView *view5 = [[UIView alloc] initWithFrame:Right];
    view5.backgroundColor = [UIColor redColor];
    view5.alpha = 0.5;
    
    UIView *view6 = [[UIView alloc] initWithFrame:UpLeft];
    view6.backgroundColor = [UIColor redColor];
    view6.alpha = 0.5;
    
    UIView *view7 = [[UIView alloc] initWithFrame:Up];
    view7.backgroundColor = [UIColor redColor];
    view7.alpha = 0.5;
    
    UIView *view8 = [[UIView alloc] initWithFrame:UpRight];
    view8.backgroundColor = [UIColor redColor];
    view8.alpha = 0.5;
    
    UIView *view9 = [[UIView alloc] initWithFrame:Select];
    view9.backgroundColor = [UIColor redColor];
    view9.alpha = 0.5;
    
    UIView *view10 = [[UIView alloc] initWithFrame:Start];
    view10.backgroundColor = [UIColor redColor];
    view10.alpha = 0.5;
    
    UIView *view11 = [[UIView alloc] initWithFrame:A];
    view11.backgroundColor = [UIColor redColor];
    view11.alpha = 0.5;
    
    UIView *view12 = [[UIView alloc] initWithFrame:B];
    view12.backgroundColor = [UIColor redColor];
    view12.alpha = 0.5;
    
    UIView *view13 = [[UIView alloc] initWithFrame:AB];
    view13.backgroundColor = [UIColor redColor];
    view13.alpha = 0.5;
    
    UIView *view14 = [[UIView alloc] initWithFrame:LPad];
    view14.backgroundColor = [UIColor redColor];
    view14.alpha = 0.5;
    
    UIView *view15 = [[UIView alloc] initWithFrame:RPad];
    view15.backgroundColor = [UIColor redColor];
    view15.alpha = 0.5;
    
    UIView *view16 = [[UIView alloc] initWithFrame:Menu];
    view16.backgroundColor = [UIColor redColor];
    view16.alpha = 0.5;
    
    [self.view addSubview:view1];
    [self.view addSubview:view2];
    [self.view addSubview:view3];
    [self.view addSubview:view4];
    [self.view addSubview:view5];
    [self.view addSubview:view6];
    [self.view addSubview:view7];
    [self.view addSubview:view8];
    [self.view addSubview:view9];
    [self.view addSubview:view10];
    [self.view addSubview:view11];
    [self.view addSubview:view12];
    [self.view addSubview:view13];
    [self.view addSubview:view14];
    [self.view addSubview:view15];
    [self.view addSubview:view16];
}



@end
