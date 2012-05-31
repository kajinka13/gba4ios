#ifndef GP2X_H
#define GP2X_H

enum
{
  GP2X_UP       = 1 << 0,
  GP2X_LEFT     = 1 << 2,
  GP2X_DOWN     = 1 << 4,
  GP2X_RIGHT    = 1 << 6,
  GP2X_START    = 1 << 8,
  GP2X_SELECT   = 1 << 9,
  GP2X_L        = 1 << 10,
  GP2X_R        = 1 << 11,
  GP2X_A        = 1 << 12,
  GP2X_B        = 1 << 13,
  GP2X_X        = 1 << 14,
  GP2X_Y        = 1 << 15,
  GP2X_VOL_DOWN = 1 << 22,
  GP2X_VOL_UP   = 1 << 23,
  GP2X_PUSH     = 1 << 27
};


#define gp2x_video_color15(R,G,B,A)  (((R&0xF8)<<8)|((G&0xF8)<<3)|((B&0xF8)>>3)|(A<<5))
#define gp2x_video_color8 (C,R,G,B)  gp2x_palette[C][0]=(G<<8)|B,gp2x_palette[C][1]=R;

void gp2x_sound_volume(u32 volume_up);
void gp2x_quit();
void gp2x_flip_screen(void);
void gp2x_video_setpalette(void);
unsigned long gp2x_joystick_read(void);
void *gp2x_sound_play(void *blah);
void gp2x_deinit(void);
void gp2x_init(int bpp, int rate, int bits, int stereo, int Hz);

#endif
