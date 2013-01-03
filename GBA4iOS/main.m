//
//  main.m
//  GBA4iOS
//
//  Created by Riley Testut on 5/23/12.
//  Copyright (c) 2012 Testut Tech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GBAAppDelegate.h"

unsigned char main_path[512];

extern int Init_joypad(void);
extern int End_joypad(void);

void ChangeWorkingDirectory(char *exe)
{
    char *s = strrchr(exe, '/');
    if (s != NULL) {
        *s = '\0';
        chdir(exe);
        *s = '/';
    }
}

int main(int argc, char **argv)
{
    ChangeWorkingDirectory(argv[0]);
    getcwd(main_path, 512);
	Init_joypad();
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([GBAAppDelegate class]));
        End_joypad();
    }
}
