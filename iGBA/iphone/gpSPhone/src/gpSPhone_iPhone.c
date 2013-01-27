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

#include <string.h>
#include <stdio.h>
#include <pthread.h>
#include <sys/select.h>

#include "../../../common.h"
#include "gpSPhone_iPhone.h"
#include "JoyPad.h"
#include "../../../main.h"

unsigned short *BaseAddress;

struct gpSPhone_Preferences preferences;
unsigned long cPad1;

/* Globals (from obj land) */
extern unsigned long __isLoadState;
extern char *__fileName;
extern int   __mute;
extern float __audioVolume;
extern int   __emulation_run;
extern char *__preferencesFilePath;
extern CoreSurfaceBufferRef __screenSurface;

/* gpSPhone Resources */
extern void sound_callback(void *userdata, u8 *stream, int length);

char __fileNameTempSave[512];
byte IS_DEBUG = 0;
byte IS_CHANGING_ORIENTATION;

AQCallbackStruct in;
long writePtr;
long playPtr;
int soundInit = 0;
struct timeval ptv;

FILE* fopen_home(char* filename, char* fileop)
{
	char* homeval;
	char  tempdir[1024];

	// Quick fix for fw 1.1.3 messed up HOME value
	FILE* fp;
	sprintf(tempdir, "/var/mobile/%s", filename);
	fp = fopen(tempdir, fileop);
	if(fp != NULL)
	{
		return fp;
	}

	sprintf(tempdir, "/var/root/%s", filename);
	fp = fopen(tempdir, fileop);
	if(fp != NULL)
	{
		return fp;
	}

	return NULL;
}

void gpSPhone_getControllerState(unsigned long  *pad1) {
    *pad1 = cPad1;
}

static void AQBufferCallback(
    void *in,
    AudioQueueRef inQ,
    AudioQueueBufferRef outQB)
{
    
    AQCallbackStruct * inData;
    short *coreAudioBuffer;
    inData = (AQCallbackStruct *)in;
    coreAudioBuffer = (short*) outQB->mAudioData;

    if (inData->frameCount > 0) {
	AudioQueueSetParameter(inQ, kAudioQueueParam_Volume, __audioVolume);
	//memset(coreAudioBuffer, 0, inData->frameCount * 4);
        sound_callback(NULL, (u8*)coreAudioBuffer, inData->frameCount * 4);
        outQB->mAudioDataByteSize = 4*inData->frameCount;
        AudioQueueEnqueueBuffer(inQ, outQB, 0, NULL);
    }
}

void gpSPhone_MuteSound(void) {
    LOGDEBUG("gpSPhone_MuteSound()");
    if( soundInit == 1 )
    {
	    gpSPhone_CloseSound();
    	global_enable_audio = 0;
	}
}

void gpSPhone_DemuteSound(void) {
    LOGDEBUG("gpSPhone_DemuteSound()");
    if( soundInit == 0 )
    {
    	gpSPhone_OpenSound(1, 44100);
    	global_enable_audio = 1;
	}
}

int gpSPhone_OpenSound(int samples_per_sync, int sample_rate) {
    Float64 sampleRate = 44100.0;
    int i;

    LOGDEBUG("gpSPhone_SoundOpen()");
    
    gpSPhone_MuteSound();
    
    if(preferences.muted)
    {
    	return 0;
    }

    soundInit = 0;

	switch(preferences.volume)
	{
		case 0:
			__audioVolume = 0.1;
			break;
		case 1:
			__audioVolume = 0.2;
			break;
		case 2:
			__audioVolume = 0.4;
			break;
		case 3:
			__audioVolume = 0.6;
			break;
		case 4:
			__audioVolume = 0.8;
			break;
		case 5:
			__audioVolume = 1.0;
			break;
		default:
			__audioVolume = 1.0;
			break;
	}
    in.mDataFormat.mSampleRate = sampleRate;
    in.mDataFormat.mFormatID = kAudioFormatLinearPCM;
    in.mDataFormat.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger
                                | kAudioFormatFlagIsPacked;
    in.mDataFormat.mBytesPerPacket = 4;
    in.mDataFormat.mFramesPerPacket = 1;
    in.mDataFormat.mBytesPerFrame = 4;
    in.mDataFormat.mChannelsPerFrame = 2;
    in.mDataFormat.mBitsPerChannel = 16;

    /* Pre-buffer before we turn on audio */
    UInt32 err;
    err = AudioQueueNewOutput(&in.mDataFormat,
                      AQBufferCallback,
                      &in,
                      NULL,
                      kCFRunLoopCommonModes,
                      0,
                      &in.queue);
   if (err) {
     LOGDEBUG("AudioQueueNewOutput err %d\n", err);
   }

   in.frameCount = 1024; //(1024 * (16)) / 4;
   UInt32 bufferBytes = in.frameCount * in.mDataFormat.mBytesPerFrame;

   for (i=0; i<AUDIO_BUFFERS; i++) {
      err = AudioQueueAllocateBuffer(in.queue, bufferBytes, &in.mBuffers[i]);
      if (err) {
	LOGDEBUG("AudioQueueAllocateBuffer[%d] err %d\n",i, err);
      }
      /* "Prime" by calling the callback once per buffer */
      AQBufferCallback (&in, in.queue, in.mBuffers[i]);
   }

   soundInit = 1;
   LOGDEBUG("gpSPhone_QueueSample.AudioQueueStart");
   err = AudioQueueStart(in.queue, NULL);

    return 0;
}

void gpSPhone_CloseSound(void) {
    LOGDEBUG("gpSPhone_CloseSound.AudioQueueDispose()");
    
	if( soundInit == 1 )
	{
		AudioQueueDispose(in.queue, true);
		soundInit = 0;
	}
}

void setDefaultPreferences() {
    preferences.frameSkip = 0;
    preferences.debug = 1;
    preferences.canDeleteROMs = 0;
    preferences.autoSave = 1;
    preferences.landscape = 0;
    preferences.muted = 0;
    preferences.scaled = 1;
	preferences.volume = 5;
    preferences.cheating = 0;
	preferences.cheat1 = 1;
	preferences.cheat2 = 1;
	preferences.cheat3 = 1;
	preferences.cheat4 = 1;
	preferences.cheat5 = 1;
	preferences.cheat6 = 1;
	preferences.cheat7 = 1;
	preferences.cheat8 = 1;
    preferences.selectedPortraitSkin = 0;
    preferences.selectedLandscapeSkin = 0;
}

int gpSPhone_LoadPreferences() {
    
    FILE *f;
    int r;

    
    setDefaultPreferences();

    /* Load Preferences */
    
    f = fopen(__preferencesFilePath, "rb");
    if (!f) 
        return -1;
    r = fread(&preferences, sizeof(preferences), 1, f);
    fclose(f);
    if (!r) 
        setDefaultPreferences();
    
        
#ifdef DEBUG
    IS_DEBUG = preferences.debug;
#else
    IS_DEBUG = 0;
#endif
    
    preferences.frameSkip = 0;
    
    LOGDEBUG("gpSPhone_LoadPreferences: Loading preferences");
    return (r) ? 0 : -1;
    
}

int gpSPhone_SavePreferences() {
    FILE *f;
    int r;

    /* Load Preferences */
    f = fopen(__preferencesFilePath, "wb");
    if (!f) return -1;
    LOGDEBUG("Saving Preferences");
    r = fwrite(&preferences, sizeof(preferences), 1, f);
    fclose(f);
    return (r) ? 0 : -1;
}

#ifdef DEBUG
void LOGDEBUG(const char *text, ...)
{
  char debug_text[1024];
  va_list args;
  FILE *f;
    
  if (!IS_DEBUG) return;

  va_start (args, text);
  vsnprintf (debug_text, sizeof (debug_text), text, args);
  va_end (args);

  f = fopen("/tmp/gpSPhone.debug", "a");
    fprintf(f, "%s\n", debug_text);
  fclose(f);
}
#endif


void *gpSPhone_Thread_Start(void *args) {
    iphone_main(__fileName);
}

void gpSPhone_Halt(void) {
	gpSPhone_MuteSound();
    __emulation_run = 0;
}

void gpSPhone_Resume(void)
{
	sprintf(__fileName, "%s", __fileNameTempSave);
}

void gpSPhone_SetSvsFile(char* filename)
{
	sprintf(__fileNameTempSave, "%s", filename);
}

void gpSPhone_DeleteTempState(void)
{
	unlink(__fileNameTempSave);
}

int gpSPhone_LoadROM(const char *fileName) {

    return 0;
}

unsigned long gpsp_gp2x_joystick_read(void)
{
	return	cPad1 | Read_joypad();
}
