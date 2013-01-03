/*

 This program is free software; you can redistribute it and/or
 modify it under the terms of the GNU General Public License
 as published by the Free Software Foundation; version 2
 of the License.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

*/

#import "../iGBA/Frameworks/GraphicsServices.h"
#import "../iGBA/Frameworks/UIKit-Private/UIView-Geometry.h"
#import "../iGBA/Frameworks/CoreSurface.h"
#import "ScreenView.h"
#import "../iGBA/iphone/gpSPhone/src/gpSPhone_iPhone.h"

#define RADIANS(degrees) ((degrees * M_PI) / 180.0)
#define DEGREES(radians) (radians * 180.0/M_PI)

CoreSurfaceBufferRef screenSurface;
static ScreenView *sharedInstance = nil;

void updateScreen() {
	[ sharedInstance performSelectorOnMainThread:@selector(updateScreen) withObject:nil waitUntilDone: NO ];
}

@implementation ScreenView 
- (id)initWithFrame:(CGRect)frame {
    LOGDEBUG("ScreenView.initWithFrame()");

    rect = frame;
    if (self == [ super initWithFrame:frame ]) {
        sharedInstance = self;
        [ self initializeGraphics ]; 
    }
    return self;
}

- (void)updateScreen {
    [ self setNeedsDisplay ];
}

- (void)dealloc {
    LOGDEBUG("ScreenView.dealloc()");
//    [ timer invalidate];
    [ screenLayer release ];
    [ super dealloc ];
}

- (void)drawRect:(CGRect)rect {
}

- (void)initializeGraphics {

    CFMutableDictionaryRef dict;
    int w, h;

    LOGDEBUG("ScreenView.initGraphics()");

    /* Landscape Resolutions */
    if(preferences.landscape)
    {
        w = 240;
        h = 160;
	}
	else
	{
        w = 240;
        h = 160;	
	}
    int pitch = w * 2, allocSize = 2 * w * h;
    LOGDEBUG("ScreenView.initializeGraphics: Allocating for %d x %d", w, h);
    char *pixelFormat = "565L";

    LOGDEBUG("ScreenView.initGraphics(): Initializing dictionary");
    dict = CFDictionaryCreateMutable(kCFAllocatorDefault, 0,
        &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    CFDictionarySetValue(dict, kCoreSurfaceBufferGlobal, kCFBooleanTrue);
    CFDictionarySetValue(dict, kCoreSurfaceBufferMemoryRegion,
        CFSTR("PurpleGFXMem"));
    CFDictionarySetValue(dict, kCoreSurfaceBufferPitch,
        CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, &pitch));
    CFDictionarySetValue(dict, kCoreSurfaceBufferWidth,
        CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, &w));
    CFDictionarySetValue(dict, kCoreSurfaceBufferHeight,
        CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, &h));
    CFDictionarySetValue(dict, kCoreSurfaceBufferPixelFormat,
        CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, pixelFormat));
    CFDictionarySetValue(dict, kCoreSurfaceBufferAllocSize,
        CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, &allocSize));

    LOGDEBUG("ScreenView.initGraphics(): Creating CoreSurface buffer");
    screenSurface = CoreSurfaceBufferCreate(dict);

    LOGDEBUG("ScreenView.initGraphics(): Locking CoreSurface buffer");
    CoreSurfaceBufferLock(screenSurface, 3);

    LOGDEBUG("ScreenView.initGraphics(): Creating screen layer");
    screenLayer = [[CALayer layer] retain];
        
    if(preferences.landscape)
    {
		CGRect FullContentBounds;
		struct CGSize size = [UIScreen mainScreen].bounds.size;
		FullContentBounds.origin.x = FullContentBounds.origin.y = 0;
		FullContentBounds.size = CGSizeMake(size.height, size.width); 
		[self setBounds: FullContentBounds];
		[self setRotationBy: 90];
		if(preferences.scaled)
		{
	        [screenLayer setFrame: CGRectMake(0.0f, 0.0f, self.bounds.size.width, self.bounds.size.height)];
		}
		else
		{
	        [screenLayer setFrame: CGRectMake(80.0f, 40.0f, 320.0f, 240.0f)];		
		}
	}
	else
	{
		if(preferences.scaled)
		{
	        [screenLayer setFrame: CGRectMake(0.0f, 0.0f, self.bounds.size.width, self.bounds.size.height)];
		}
		else
		{
	        [screenLayer setFrame: CGRectMake(40.0f, 40.0f, 240.0f, 160.0f)];		
		}
	}
    
    [screenLayer setContents: screenSurface];
    [screenLayer setOpaque: YES];

    LOGDEBUG("ScreenView.initGraphics(): Adding layer as sublayer");
    [self.layer addSublayer: screenLayer ];

    LOGDEBUG("ScreenView.initGraphics(): Unlocking CoreSurface buffer");
    CoreSurfaceBufferUnlock(screenSurface);

    BaseAddress = CoreSurfaceBufferGetBaseAddress(screenSurface);
    LOGDEBUG("ScreenView.initializeGraphics: New base address %p", BaseAddress);
/*    
    timer = [NSTimer scheduledTimerWithTimeInterval:0.100
                 target:self
                 selector:@selector(updateScreen)
                 userInfo:nil
                 repeats:YES];
*/                
    LOGDEBUG("ScreenView.initGraphics(): Done");
    
    [self rotateForDeviceOrientation:UIDeviceOrientationPortrait]; // Sets default layout
}

- (void)rotateForDeviceOrientation:(UIDeviceOrientation)deviceOrientation {
    
    [CATransaction begin]; 
    [CATransaction setValue: (id) kCFBooleanTrue forKey: kCATransactionDisableActions];
    
    CGFloat yOffset = 44 * ([UIScreen mainScreen].bounds.size.height == 568);
    
    if (deviceOrientation == UIDeviceOrientationLandscapeLeft) {
        self.transform = CGAffineTransformMakeRotation(RADIANS(90.0));
        self.frame = CGRectMake(0, 0, 320, [UIScreen mainScreen].bounds.size.height);
        if (preferences.selectedLandscapeSkin == 0) {
            [screenLayer setFrame:CGRectMake(120.0f + yOffset, 40.0f, 240.0f, 160.0f)];
        }
        else {
            if (preferences.scaled) {
                [screenLayer setFrame:CGRectMake(0.0f + yOffset, 0.0f, 480.0f, 320.0f)];
            }
            else {
                [screenLayer setFrame: CGRectMake(120.0f + yOffset, 80.0f, 240.0f, 160.0f)];
               
            }
        }
    }
    else if (deviceOrientation == UIDeviceOrientationLandscapeRight) {
        self.transform = CGAffineTransformMakeRotation(RADIANS(270.0));
        self.frame = CGRectMake(0, 0, 320, [UIScreen mainScreen].bounds.size.height);
        if (preferences.selectedLandscapeSkin == 0) {
            [screenLayer setFrame:CGRectMake(120.0f + yOffset, 40.0f, 240.0f, 160.0f)];
        }
        else {
            if (preferences.scaled) {
                [screenLayer setFrame:CGRectMake(0.0f + yOffset, 0.0f, 480.0f, 320.0f)];
            }
            else {
                [screenLayer setFrame: CGRectMake(120.0f + yOffset, 80.0f, 240.0f, 160.0f)];
                
            }
        }
    }
    else if (deviceOrientation == UIDeviceOrientationPortrait) {
        self.transform = CGAffineTransformMakeRotation(RADIANS(0.0));
        self.frame = CGRectMake(0, 0, 320, 240);
        if (preferences.scaled) {
	        [screenLayer setFrame: CGRectMake(0.0f, 0.0f + yOffset, 320.0f, 240.0f)];
		}
		else {
	        [screenLayer setFrame: CGRectMake(40.0f, 40.0f + yOffset, 240.0f, 160.0f)];
		}
    }
    else if (deviceOrientation == UIDeviceOrientationPortraitUpsideDown) {
        self.transform = CGAffineTransformMakeRotation(RADIANS(180.0));
        self.frame = CGRectMake(0, 0, 320, 240);
        if (preferences.scaled) {
	        [screenLayer setFrame: CGRectMake(0.0f, 0.0f + yOffset, 320.0f, 240.0f)];
		}
		else {
	        [screenLayer setFrame: CGRectMake(40.0f, 40.0f + yOffset, 240.0f, 160.0f)];		
		}
    }
    
    [CATransaction commit];
    
}

@end
