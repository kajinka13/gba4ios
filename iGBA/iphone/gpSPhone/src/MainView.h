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
#import "../../../Frameworks/UIKit-Private/UITransitionView.h"
#import "../../../Frameworks/UIKit-Private/UIPreferencesTable.h"
#import <UIKit/UISegmentedControl.h>
#import "../../../Frameworks/UIKit-Private/UISwitchControl.h"
#import "../../../Frameworks/UIKit-Private/UIPreferencesTextTableCell.h"
#import "../../../Frameworks/UIKit-Private/UIButtonBar.h"
#import "FileBrowser.h"
#import "EmulationView.h"

#import "../../../Frameworks/UIKit-Private/UIAlertSheet.h"

extern char *__fileName;
extern int __screenOrientation;

extern void gotoMenu();

#define ROM_PATH1 "/var/root/Media/ROMs/GBA"
#define ROM_PATH2 "/var/mobile/Media/ROMs/GBA"

@interface MainView : UIView 
{
         NSString *m_currentFile;

         CGRect    mainRect;
         UINavigationBar    *navBar;
         UITransitionView   *transitionView;
         FileBrowser        *fileBrowser;
         FileBrowser        *savedBrowser;
         FileBrowser        *recentBrowser;
         FileBrowser        *bookmarkBrowser;
         EmulationView      *emuView;
         UIPreferencesTable *prefTable;
         UIButtonBar        *buttonBar;
         UINavigationItem   *navItem;

         /* Caching for preference table */
         NSString *currentGameTitle;

         int       currentView;
         int       currentBrowserPage;
         pthread_t emulation_tid;

         UIPreferencesTableCell *cells[20][20];
         UIPreferencesTableCell *groupcell[10];
         UISegmentedControl *frameControl;
	 UISegmentedControl *skinControl;
         UISegmentedControl *palControl;
         UISegmentedControl *cpuControl;
		 UISegmentedControl *volumeControl;
         UISwitchControl *sensoryControl;
	 UISwitchControl *scaledControl;
	UISwitchControl *cheatControl;
	UISwitchControl *cheat1Control;
	UISwitchControl *cheat2Control;
	UISwitchControl *cheat3Control;
	UISwitchControl *cheat4Control;
	UISwitchControl *cheat5Control;
	UISwitchControl *cheat6Control;
	UISwitchControl *cheat7Control;
	UISwitchControl *cheat8Control;
	
	 UISwitchControl *mutedControl;
#ifdef DEBUG
         UISwitchControl *debugControl;
#endif
         UISwitchControl *landscapeControl;
         UISwitchControl *delromsControl;
         UISwitchControl *autosaveControl;
         UISwitchControl *gamegenieControl;
         UISwitchControl *enlargeControl;
         UISwitchControl *suspendControl;
         UISwitchControl *bassControl;
         UISegmentedControl *spkControl;
         BOOL allowDeleteROMs;
         NSString *versionString;
         UIWindow *parentWindow;

         UIAlertSheet *badROMSheet;
         UIAlertSheet *saveStateSheet;
         UIAlertSheet *selectROMSheet;
         UIAlertSheet *supportSheet;
}

- (id)initWithFrame:(CGRect)frame;
- (void)dealloc;
- (void)startEmulator;
- (void)stopEmulator:(BOOL)promptForSave;
- (void)resumeEmulator;
- (void)suspendEmulator;
- (void)setNavBar;
- (BOOL)isBrowsing;
- (UIPreferencesTable *)createPrefPane;
- (FileBrowser *)createBrowser;
- (EmulationView *)createEmulationView;
- (UINavigationBar *)createNavBar;
- (UITransitionView *)createTransitionView:(int)offset;
- (BOOL)savePreferences;
- (int)numberOfGroupsInPreferencesTable:(UIPreferencesTable *)aTable;
- (int)preferencesTable:(UIPreferencesTable *)aTable numberOfRowsInGroup:(int)group;
- (UIPreferencesTableCell *)preferencesTable:(UIPreferencesTable *)aTable cellForGroup:(int)group;
- (UIPreferencesTableCell *)preferencesTable:(UIPreferencesTable *)aTable cellForRow:(int)row inGroup:(int)group;
- (float)preferencesTable:(UIPreferencesTable *)aTable heightForRow:(int)row inGroup:(int)group withProposedHeight:(float)proposed;
- (BOOL)preferencesTable:(UIPreferencesTable *)aTable isLabelGroup:(int)group;
- (int)getCurrentView;
- (void)reloadBrowser;
- (UIButtonBar *)createButtonBar;
- (void)buttonBarItemTapped:(id)sender;
- (NSArray *)buttonBarItems;
- (void)reloadButtonBar;
- (void)load;
- (BOOL)isBookmarked:(NSString *)file;
- (void)addBookmark:(NSString *)file;
- (void)gotoMenu;

#define CUR_BROWSER		0x00
#define CUR_PREFERENCES		0x01
#define CUR_EMULATOR		0x02
#define CUR_EMULATOR_SUSPEND	0x04

#define CB_NORMAL 0x00
#define CB_SAVED  0x01
#define CB_RECENT 0x02
#define CB_BOOKMARKS 0x03

extern NSString *kUIButtonBarButtonAction;
extern NSString *kUIButtonBarButtonInfo;
extern NSString *kUIButtonBarButtonInfoOffset;
extern NSString *kUIButtonBarButtonSelectedInfo;
extern NSString *kUIButtonBarButtonStyle;
extern NSString *kUIButtonBarButtonTag;
extern NSString *kUIButtonBarButtonTarget;
extern NSString *kUIButtonBarButtonTitle;
extern NSString *kUIButtonBarButtonTitleVerticalHeight;
extern NSString *kUIButtonBarButtonTitleWidth;
extern NSString *kUIButtonBarButtonType;

@end
