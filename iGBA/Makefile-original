CC = /usr/local/bin/arm-apple-darwin8-gcc
LD = $(CC)
VERSION = 1.8.0
LDFLAGS = -lobjc \
          -framework CoreFoundation \
          -framework Foundation \
          -framework UIKit \
          -framework LayerKit \
          -framework CoreGraphics \
          -framework GraphicsServices \
          -framework CoreSurface \
          -framework CoreAudio \
          -framework Celestial \
          -framework AudioToolbox \
          -lz

#CFLAGS = -DDEBUG -O2 -Wall -funroll-loops -DVERSION='"$(VERSION)"'
CFLAGS	= -DARM_ARCH -DGP2X_BUILD -msoft-float -march=armv6k -maspen-version-min=1.0 -fpeel-loops -O3 -fnested-functions -funsigned-char -fno-common -fno-builtin -falign-functions -fomit-frame-pointer -fweb -fstrict-aliasing -fstrength-reduce -fexpensive-optimizations -finline -finline-functions -funroll-loops -DVERSION='"$(VERSION)"'
#-mcpu=arm1176jzf-s -fpeel-loops
#-msoft-float 

all:	gpSPhone

#iphone/video_blend.o 

gpSPhone:	iphone/gpSPhone/src/JoyPad.o iphone/gpSPhone/src/iphone.o iphone/gpSPhone/src/main.o iphone/gpSPhone/src/gpSPhoneApp.o iphone/gpSPhone/src/ControllerView.o iphone/gpSPhone/src/MainView.o iphone/gpSPhone/src/FileTable.o iphone/gpSPhone/src/FileBrowser.o iphone/gpSPhone/src/EmulationView.o iphone/gpSPhone/src/ScreenView.o iphone/gpSPhone/src/gpSPhone_iPhone.o iphone/arm_stub_c.o iphone/font.o iphone/display.o cheats.o zip.o gui.o main.o cpu.o sound.o input.o memory.o video.o iphone/arm_asm_stub.o cpu_threaded.o 
	$(LD) ${CFLAGS} $(LDFLAGS) -o $@ $^

%.o:	%.m
	$(CC) ${CFLAGS} -c $< -o $@

%.o:	%.c
	$(CC) ${CFLAGS} -c $< -o $@

%.o:	%.S
	$(CC) -c $< -o $@

%.z:	%.c
	$(CC) ${CFLAGS} -S $< -o $@

clean:
	rm -f ./*.o iphone/*.o iphone/gpSPhone/*.o iphone/gpSPhone/src/*.o gpSPhone src/*.gch
	rm -rf ./build
