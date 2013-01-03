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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "../iGBA/Frameworks/CoreSurface.h"
#include <pthread.h>

#import <QuartzCore/QuartzCore.h>

extern CoreSurfaceBufferRef screenSurface;

@interface ScreenView : UIView 
{
	NSTimer *timer;
    CGRect rect;
    CALayer *screenLayer;
}

void updateScreen();

- (id)initWithFrame:(CGRect)frame;
- (void)dealloc;
- (void)drawRect:(CGRect)frame;
- (void)initializeGraphics;
- (void)rotateForDeviceOrientation:(UIDeviceOrientation)deviceOrientation;

@end
