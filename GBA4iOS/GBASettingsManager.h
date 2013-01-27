//
//  GBASettingsManager.h
//  GBA4iOS
//
//  Created by Riley Testut on 1/26/13.
//  Copyright 2013 Testut Tech. All rights reserved.
//	File created using Singleton XCode Template by Mugunth Kumar (http://blog.mugunthkumar.com)
//  More information about this template on the post http://mk.sg/89
//  Permission granted to do anything, commercial/non-commercial with this file apart from removing the line/URL above

#import <Foundation/Foundation.h>

@interface GBASettingsManager : NSObject

@property (nonatomic) NSInteger frameSkip;
@property (nonatomic) BOOL scaled;
@property (nonatomic) NSInteger portraitSkin;
@property (nonatomic) NSInteger landscapeSkin;
@property (nonatomic) BOOL cheatsEnabled;
@property (nonatomic) BOOL autoSave;
@property (nonatomic) BOOL checkForUpdates;

+ (GBASettingsManager*) sharedManager;

@end
