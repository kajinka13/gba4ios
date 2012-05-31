CC = /Developer/Platforms/iPhoneOS.platform/Developer/usr/bin/clang++
LD = $(CC)
VERSION = 1.8.0

VERSION=5.1
CFLAGS = -F/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS${VERSION}.sdk/System/Library/Frameworks -F/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS${VERSION}.sdk/System/Library/PrivateFrameworks -I../../ -I../../Classes/ -I/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/usr/lib/clang/3.0/include   -L/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS${VERSION}.sdk/usr/lib -I/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS${VERSION}.sdk/usr/include/

LDFLAGS = -lobjc \
          -framework CoreFoundation \
          -framework Foundation \
          -framework UIKit \
          -framework CoreGraphics \
          -framework GraphicsServices \
          -framework CoreSurface \
          -framework CoreAudio \
          -framework Celestial \
          -framework AudioToolbox \
          -L/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS${VERSION}.sdk/usr/lib/system \
          -lz

#CFLAGS = -DDEBUG -O2 -Wall -funroll-loops -DVERSION='"$(VERSION)"'
CFLAGS	+= -miphoneos-version-min=${VERSION} -DARM_ARCH -DGP2X_BUILD -msoft-float -arch armv7 -march=armv6k -maspen-version-min=1.0 -fpeel-loops -O3 -fnested-functions -funsigned-char -fno-common -fno-builtin -falign-functions -fomit-frame-pointer -fweb -fstrict-aliasing -fstrength-reduce -fexpensive-optimizations -finline -finline-functions -funroll-loops -DVERSION='"$(VERSION)"'

#-mcpu=arm1176jzf-s -fpeel-loops
#-msoft-float 

all:	gpSPhone

#iphone/video_blend.o 

gpSPhone: iphone/gpSPhone/src/JoyPad.o iphone/gpSPhone/src/iphone.o iphone/gpSPhone/src/main.o iphone/gpSPhone/src/gpSPhoneApp.o iphone/gpSPhone/src/ControllerView.o iphone/gpSPhone/src/MainView.o iphone/gpSPhone/src/FileTable.o iphone/gpSPhone/src/FileBrowser.o iphone/gpSPhone/src/EmulationView.o iphone/gpSPhone/src/ScreenView.o iphone/gpSPhone/src/gpSPhone_iPhone.o iphone/arm_stub_c.o iphone/font.o iphone/display.o cheats.o zip.o gui.o main.o cpu.o sound.o input.o memory.o video.o 
	$(LD) ${CFLAGS} $(LDFLAGS) -o $@ $^
    #iphone/arm_asm_stub.o cpu_threaded.o

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
