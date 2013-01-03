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

#ifndef GPSPHONE_IPHONE_H
#define GPSPHONE_IPHONE_H

#import <AudioToolbox/AudioQueue.h>
#import "../../../Frameworks/CoreSurface.h"

#define BIT_U			0x1
#define BIT_D			0x10
#define BIT_L 			0x4
#define BIT_R		 	0x40
#define BIT_SEL			(1<<9)
#define BIT_ST			(1<<8)
#define BIT_LPAD		(1<<10)
#define BIT_RPAD		(1<<11)
#define BIT_HARDA		(1<<12)
#define BIT_HARDB		(1<<13)
#define BIT_HARDX		(1<<14)
#define BIT_HARDY		(1<<15)
#define BIT_VOL_UP		(1<<23)
#define BIT_VOL_DOWN	(1<<22)
#define BIT_PUSH		(1<<27)

#define BIT_A			BIT_HARDB
#define BIT_B			BIT_HARDX

extern void updateScreen();

#define gp2x_flipscreen() updateScreen()

typedef unsigned char byte;

struct gpSPhone_Preferences {
    int frameSkip;
    byte debug;
    byte canDeleteROMs;
    byte autoSave;
    byte landscape;
    byte allowSuspend;
    bool scaled;
    byte muted;
    int selectedPortraitSkin;
    int selectedLandscapeSkin;
	byte volume;
	bool cheating;
	byte cheat1;
	byte cheat2;
	byte cheat3;
	byte cheat4;
	byte cheat5;
	byte cheat6;
	byte cheat7;
	byte cheat8;
};

void setDefaultPreferences();
int gpSPhone_SavePreferences();
int gpSPhone_LoadPreferences();

extern unsigned long cPad1;

/* STUBs to emulator core */

void *gpSPhone_Thread_Start(void *args);
void *gpSPhone_Thread_Resume(void *args);
void gpSPhone_Halt(void);
void gpSPhone_Resume(void);
int gpSPhone_LoadROM(const char *fileName);
void gpSPhone_DeleteTempState(void);

void gpSPhone_SetSvsFile(char* filename);

void gpSPhone_MuteSound(void);
void gpSPhone_DemuteSound(void);

int gpSPhone_OpenSound(int samples_per_sync, int sample_rate);
void gpSPhone_CloseSound(void);
void gpSPhone_StopSound();
void gpSPhone_StartSound();
FILE* fopen_home(char* filename, char* fileop);

extern byte IS_DEBUG;
extern byte IS_CHANGING_ORIENTATION;
extern unsigned short  *BaseAddress;
extern int __screenOrientation;
extern struct gpSPhone_Preferences preferences;

/* Audio Resources */
#define AUDIO_BUFFERS 2
#define AUDIO_PRECACHE 3
#define WAVE_BUFFER_SIZE 735
#define WAVE_BUFFER_BANKS 25

typedef struct AQCallbackStruct {
    AudioQueueRef queue;
    UInt32 frameCount;
    AudioQueueBufferRef mBuffers[AUDIO_BUFFERS];
    AudioStreamBasicDescription mDataFormat;
} AQCallbackStruct;

#ifndef DEBUG
#define LOGDEBUG(...) while(0){}
#else
void LOGDEBUG (const char *err, ...) ;
#endif

#endif
