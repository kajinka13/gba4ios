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

#import "GraphicsServices.h"
#import "UIView-Geometry.h"
#import "CoreSurface.h"
#import "ScreenViewGameBoyColor.h"
#import "app_iPhone.h"

CoreSurfaceBufferRef screenSurfaceGBC;
static ScreenViewGameBoyColor *sharedInstance = nil;

void updateGBCScreen() {
	[sharedInstance performSelectorOnMainThread:@selector(updateScreen) withObject:nil waitUntilDone:NO];
}

@implementation ScreenViewGameBoyColor
- (id)initWithFrame:(CGRect)frame {
    DLog("ScreenView.initWithFrame()");

    rect = frame;
    if ((self = [ super initWithFrame:frame ])) {
        sharedInstance = self;
        [ self initializeGraphics ]; 
    }
    return self;
}

- (void)updateScreen {
    [self setNeedsDisplay];
}

// DO NOT DELETE THIS METHOD
// It may be a performance hit, but this is required to draw the Game Boy Color
- (void)drawRect:(CGRect)rect { }

- (void)dealloc {
    DLog("ScreenView.dealloc()");
}

- (void)initializeGraphics {

    CFMutableDictionaryRef dict;
    int w, h;

    DLog("ScreenView.initGraphics()");

    /* Landscape Resolutions */
    if(preferences.landscape)
    {
        w = 160;
        h = 144;
	}
	else
	{
        w = 160;
        h = 144;	
	}
    int pitch = w * 2, allocSize = 2 * w * h;
    DLog("ScreenView.initializeGraphics: Allocating for %d x %d", w, h);
    char *pixelFormat = "565L";

    DLog("ScreenView.initGraphics(): Initializing dictionary");
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

    DLog("ScreenView.initGraphics(): Creating CoreSurface buffer");
    screenSurfaceGBC = CoreSurfaceBufferCreate(dict);

    DLog("ScreenView.initGraphics(): Locking CoreSurface buffer");
    CoreSurfaceBufferLock(screenSurfaceGBC, 3);

    DLog("ScreenView.initGraphics(): Creating screen layer");
    screenLayer = [CALayer layer];
    if(preferences.landscape)
    {
		CGRect FullContentBounds;
//		struct CGSize size = [UIHardware mainScreenSize];
        CGSize size = [[UIScreen mainScreen] bounds].size;
		FullContentBounds.origin.x = FullContentBounds.origin.y = 0;
		FullContentBounds.size = CGSizeMake(size.height, size.width); 
		[self setBounds: FullContentBounds];
		[self setRotationBy: 90];
		if(preferences.scaled)
		{
	        [screenLayer setFrame: CGRectMake(0.0f, 0.0f, 480.0f, 320.0f)];
		}
		else
		{
	        [screenLayer setFrame: CGRectMake(80.0f, 0.0f, 320.0f, 288.0f)];		
		}
	}
	else
	{
		if(preferences.scaled)
		{
	        [screenLayer setFrame: CGRectMake(0.0f, 0.0f, 320.0f, 240.0f)];
		}
		else
		{
	        [screenLayer setFrame: CGRectMake(27.0f, 0.0f, 266.0f, 240.0f)];
		}
	}
    [screenLayer setContents: (__bridge id)(screenSurfaceGBC)];
    [screenLayer setOpaque: YES];

    DLog("ScreenView.initGraphics(): Adding layer as sublayer");
    [ [ self layer ] addSublayer: screenLayer ];

    DLog("ScreenView.initGraphics(): Unlocking CoreSurface buffer");
    CoreSurfaceBufferUnlock(screenSurfaceGBC);

    GBCBaseAddress = CoreSurfaceBufferGetBaseAddress(screenSurfaceGBC);
    DLog("ScreenView.initializeGraphics: New base address %p", GBCBaseAddress);               
    DLog("ScreenView.initGraphics(): Done");
}

@end
