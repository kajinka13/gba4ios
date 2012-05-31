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
#import "../../../Frameworks/GraphicsServices.h"
#import <UIKit/UIKit.h>
#import "../../../Frameworks/UIKit-Private/UIAlertSheet.h"
#import "../../../Frameworks/AVSystemController.h"
#import "MainView.h"
#import "gpSPhone_iPhone.h"

#include <sys/stat.h>
#include <stdio.h>
#include <unistd.h>

#define INIT_PATH "Library/Preferences/gpSPhone.init"

extern float __audioVolume;

@interface gpSPhoneApp : UIApplication
{
    UIWindow *window;

    AVSystemController  *avs;
    NSString *audioDeviceName;
    UIAlertSheet *feedMeSheet;
    int screenOrientation;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification;
- (void)applicationWillTerminate;
- (void)applicationWillSuspendForEventsOnly;
- (void)applicationSuspend:(struct __GSEvent *)event;

@end
