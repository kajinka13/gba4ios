//
//  GBCControllerViewController.m
//  GBA4iOS
//
//  Created by Ethan Mick on 12/28/12.
//  Copyright (c) 2012 Testut Tech. All rights reserved.
//

#import "GBCControllerViewController.h"
#import "GBCEmulatorViewController.h"

#define INP_BUTTON_UP				(0)
#define INP_BUTTON_DOWN				(1)
#define INP_BUTTON_LEFT				(2)
#define INP_BUTTON_RIGHT			(3)
#define INP_BUTTON_HARDB			(4)
#define INP_BUTTON_HARDA			(5)
#define INP_BUTTON_HARDAB			(6)
#define INP_BUTTON_START			(7)
#define INP_BUTTON_SELECT			(8)


#define BIT_U			(1<<INP_BUTTON_UP)
#define BIT_D			(1<<INP_BUTTON_DOWN)
#define BIT_L 			(1<<INP_BUTTON_LEFT)
#define BIT_R		 	(1<<INP_BUTTON_RIGHT)
#define BIT_B			(1<<INP_BUTTON_HARDB)
#define BIT_A			(1<<INP_BUTTON_HARDA)
#define BIT_AB			(1<<INP_BUTTON_HARDAB)
#define BIT_ST			(1<<INP_BUTTON_START)
#define BIT_SEL			(1<<INP_BUTTON_SELECT)

#define BIT_LPAD1		(1<<29)
#define BIT_RPAD1		(1<<30)
#define BIT_MENU		(1<<31)

extern unsigned long cPad1GBC;

@interface GBCControllerViewController ()

@end

static unsigned long pressedButtons;
static unsigned long newtouches[10];
static unsigned long oldtouches[10];

@implementation GBCControllerViewController

@synthesize imageView, readyToSustain, sustainedButtons;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad { [super viewDidLoad];
    
	self.view.multipleTouchEnabled = YES;
    self.sustainedButtons = [NSMutableSet setWithCapacity:12];
    
    CGFloat yOffset = 88.0f * ([UIScreen mainScreen].bounds.size.height == 568);
    
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 240 + yOffset, 320, 240)];
    [self.view addSubview:self.imageView];
    self.imageView.image = [self getControllerImage];
    
    [self getControllerCoords];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIImage *)getControllerImage {
    NSString *controllerFilename;
    UIImage *image;
    
    if(preferences.landscape)
    {
	    controllerFilename = [ NSString stringWithFormat:@"gbc_controller_fs%d.png", preferences.selectedSkin ];
	}
	else
	{
	    controllerFilename = [ NSString stringWithFormat:@"gbc_controller_hs%d.png", preferences.selectedSkin ];
	}
    
    LOGDEBUG("ControllerView.getControllerImage(): Loading controller image %s",
             [ controllerFilename cStringUsingEncoding: NSASCIIStringEncoding ]);
    image = [UIImage imageNamed:controllerFilename];
    return image;
};

- (void)getControllerCoords {
	char string[256];
	char cFileName[256];
	FILE *fp;
	NSString *file;
	if(preferences.landscape)
	{
		file = [ NSString stringWithFormat:@"gbc_controller_fs%d.txt", preferences.selectedSkin ];
	}
	else
	{
		file = [ NSString stringWithFormat:@"gbc_controller_hs%d.txt", preferences.selectedSkin ];
	}
	strlcpy(cFileName, [file cStringUsingEncoding:NSASCIIStringEncoding], sizeof(cFileName));
    
    CGFloat yOffset = 0.0;
    
    if ([UIScreen mainScreen].bounds.size.height == 568 && !preferences.landscape) { // The landscape controllers have the new coordinates in the text file.
        yOffset = 88.0f;
    }
    
	fp = fopen(cFileName, "r");
	if (fp)
	{
		int i = 0;
        while(fgets(string, 256, fp) != NULL && i < 16)
        {
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
                case 1:    Down   		= CGRectMake( coords[0], coords[1] + yOffset, coords[2], coords[3] ); break;
                case 2:    DownRight    = CGRectMake( coords[0], coords[1] + yOffset, coords[2], coords[3] ); break;
                case 3:    Left  		= CGRectMake( coords[0], coords[1] + yOffset, coords[2], coords[3] ); break;
                case 4:    Right  		= CGRectMake( coords[0], coords[1] + yOffset, coords[2], coords[3] ); break;
                case 5:    UpLeft     	= CGRectMake( coords[0], coords[1] + yOffset, coords[2], coords[3] ); break;
                case 6:    Up     		= CGRectMake( coords[0], coords[1] + yOffset, coords[2], coords[3] ); break;
                case 7:    UpRight  	= CGRectMake( coords[0], coords[1] + yOffset, coords[2], coords[3] ); break;
                case 8:    Select		= CGRectMake( coords[0], coords[1] + yOffset, coords[2], coords[3] ); break;
                case 9:	   Start	   	= CGRectMake( coords[0], coords[1] + yOffset, coords[2], coords[3] ); break;
                case 10:   ButtonA     	= CGRectMake( coords[0], coords[1] + yOffset, coords[2], coords[3] ); break;
                case 11:   ButtonB     	= CGRectMake( coords[0], coords[1] + yOffset, coords[2], coords[3] ); break;
                case 12:   ButtonAB    	= CGRectMake( coords[0], coords[1] + yOffset, coords[2], coords[3] ); break;
                case 13:   LPad			= CGRectMake( coords[0], coords[1] + yOffset, coords[2], coords[3] ); break;
                case 14:   RPad			= CGRectMake( coords[0], coords[1] + yOffset, coords[2], coords[3] ); break;
                case 15:   Menu			= CGRectMake( coords[0], coords[1] + yOffset, coords[2], coords[3] ); break;
			}
           	i++;
        }
        fclose(fp);
		fixedRects = false;
    }
    
    //[self showControllerButtons]; // For debugging
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
    
    UIView *view11 = [[UIView alloc] initWithFrame:ButtonA];
    view11.backgroundColor = [UIColor redColor];
    view11.alpha = 0.5;
    
    UIView *view12 = [[UIView alloc] initWithFrame:ButtonB];
    view12.backgroundColor = [UIColor redColor];
    view12.alpha = 0.5;
    
    UIView *view13 = [[UIView alloc] initWithFrame:ButtonAB];
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

#pragma mark - Touches

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
            
			if (CGRectContainsPoint(Left, point))
			{
				pressedButtons |= BIT_L;
				newtouches[i] = BIT_L;
                if (self.readyToSustain) {
                    [self.sustainedButtons addObject:[NSNumber numberWithUnsignedInt:BIT_L]];
                }
			}
			else if (CGRectContainsPoint(Right, point))
			{
				pressedButtons |= BIT_R;
				newtouches[i] = BIT_R;
                if (self.readyToSustain) {
                    [self.sustainedButtons addObject:[NSNumber numberWithUnsignedInt:BIT_R]];
                }
			}
			else if (CGRectContainsPoint(Up, point))
			{
				pressedButtons |= BIT_U;
				newtouches[i] = BIT_U;
                if (self.readyToSustain) {
                    [self.sustainedButtons addObject:[NSNumber numberWithUnsignedInt:BIT_U]];
                }
			}
			else if (CGRectContainsPoint(Down, point))
			{
				pressedButtons |= BIT_D;
				newtouches[i] = BIT_D;
                if (self.readyToSustain) {
                    [self.sustainedButtons addObject:[NSNumber numberWithUnsignedInt:BIT_D]];
                }
			}
			else if (CGRectContainsPoint(UpLeft, point))
			{
				pressedButtons |= BIT_U | BIT_L;
				newtouches[i] = BIT_U | BIT_L;
                if (self.readyToSustain) {
                    [self.sustainedButtons addObject:[NSNumber numberWithUnsignedInt:BIT_U]];
                    [self.sustainedButtons addObject:[NSNumber numberWithUnsignedInt:BIT_L]];
                }
			}
			else if (CGRectContainsPoint(DownLeft, point))
			{
				pressedButtons |= BIT_D | BIT_L;
				newtouches[i] = BIT_D | BIT_L;
                if (self.readyToSustain) {
                    [self.sustainedButtons addObject:[NSNumber numberWithUnsignedInt:BIT_D]];
                    [self.sustainedButtons addObject:[NSNumber numberWithUnsignedInt:BIT_L]];
                }
			}
			else if (CGRectContainsPoint(UpRight, point))
			{
				pressedButtons |= BIT_U | BIT_R;
				newtouches[i] = BIT_U | BIT_R;
                if (self.readyToSustain) {
                    [self.sustainedButtons addObject:[NSNumber numberWithUnsignedInt:BIT_U]];
                    [self.sustainedButtons addObject:[NSNumber numberWithUnsignedInt:BIT_R]];
                }
			}
			else if (CGRectContainsPoint(DownRight, point))
			{
				pressedButtons |= BIT_D | BIT_R;
				newtouches[i] = BIT_D | BIT_R;
                if (self.readyToSustain) {
                    [self.sustainedButtons addObject:[NSNumber numberWithUnsignedInt:BIT_D]];
                    [self.sustainedButtons addObject:[NSNumber numberWithUnsignedInt:BIT_R]];
                }
			}
            else if (CGRectContainsPoint(ButtonA, point))
			{
				pressedButtons |= BIT_A;
				newtouches[i] = BIT_A;
                if (self.readyToSustain) {
                    [self.sustainedButtons addObject:[NSNumber numberWithUnsignedInt:BIT_A]];
                }
			}
            else if (CGRectContainsPoint(ButtonB, point))
			{
				pressedButtons |= BIT_B;
				newtouches[i] = BIT_B;
                if (self.readyToSustain) {
                    [self.sustainedButtons addObject:[NSNumber numberWithUnsignedInt:BIT_B]];
                }
			}
            else if (CGRectContainsPoint(ButtonAB, point))
			{
				pressedButtons |= BIT_A | BIT_B;
				newtouches[i] = BIT_A | BIT_B;
                if (self.readyToSustain) {
                    [self.sustainedButtons addObject:[NSNumber numberWithUnsignedInt:BIT_A]];
                    [self.sustainedButtons addObject:[NSNumber numberWithUnsignedInt:BIT_B]];
                }
			}
			else if (CGRectContainsPoint(LPad, point))
			{
				pressedButtons |= BIT_LPAD1;
				newtouches[i] = BIT_LPAD1;
                if (self.readyToSustain) {
                    [self.sustainedButtons addObject:[NSNumber numberWithUnsignedInt:BIT_LPAD1]];
                    [self.sustainedButtons addObject:[NSNumber numberWithUnsignedInt:BIT_LPAD1]];
                }
			}
			else if (CGRectContainsPoint(RPad, point))
			{
				pressedButtons |= BIT_RPAD1;
				newtouches[i] = BIT_RPAD1;
                if (self.readyToSustain) {
                    [self.sustainedButtons addObject:[NSNumber numberWithUnsignedInt:BIT_RPAD1]];
                    [self.sustainedButtons addObject:[NSNumber numberWithUnsignedInt:BIT_RPAD1]];
                }
			}
			else if (CGRectContainsPoint(Select, point))
			{
				pressedButtons |= BIT_SEL;
				newtouches[i] = BIT_SEL;
                if (self.readyToSustain) {
                    [self.sustainedButtons addObject:[NSNumber numberWithUnsignedInt:BIT_SEL]];
                }
			}
			else if (CGRectContainsPoint(Start, point))
			{
				pressedButtons |= BIT_ST;
				newtouches[i] = BIT_ST;
                if (self.readyToSustain) {
                    [self.sustainedButtons addObject:[NSNumber numberWithUnsignedInt:BIT_ST]];
                }
			}
			else if (CGRectContainsPoint(Menu, point)) {
                [self.delegate controllerDidPauseROM:self];
//                [emulatorViewController pauseMenu];
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
    
    /*
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
     */
    
    cPad1GBC = pressedButtons;
    
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


@end
