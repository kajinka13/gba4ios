//
//  GBASettingsManager.m
//  GBA4iOS
//
//  Created by Riley Testut on 1/26/13.
//  Copyright 2013 Testut Tech. All rights reserved.
//	File created using Singleton XCode Template by Mugunth Kumar (http://blog.mugunthkumar.com)
//  More information about this template on the post http://mk.sg/89	
//  Permission granted to do anything, commercial/non-commercial with this file apart from removing the line/URL above

#import "GBASettingsManager.h"
#import "../iGBA/iphone/gpSPhone/src/gpSPhone_iPhone.h"

@implementation GBASettingsManager

#pragma mark -
#pragma mark Singleton Methods

+ (GBASettingsManager*)sharedManager {

	static GBASettingsManager *_sharedInstance;
	if(!_sharedInstance) {
		static dispatch_once_t oncePredicate;
		dispatch_once(&oncePredicate, ^{
			_sharedInstance = [[super allocWithZone:nil] init];
            
            [_sharedInstance updateSettings];
            
			});
		}

		return _sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone {	

	return [self sharedManager];
}


- (id)copyWithZone:(NSZone *)zone {
	return self;	
}

#pragma mark - Private

- (void)updateSettings {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSDictionary *defaultPreferences = @{@"scaled" : @YES, @"autoSave" : @YES, @"checkForUpdates" : @YES};
    
    [defaults registerDefaults:defaultPreferences];
    
    self.frameSkip = [defaults integerForKey:@"frameskip"];
    self.scaled = [defaults boolForKey:@"scaled"];
    self.portraitSkin = [defaults integerForKey:@"portraitSkin"];
    self.landscapeSkin = [defaults integerForKey:@"landscapeSkin"];
    self.cheatsEnabled = [defaults boolForKey:@"cheatsEnabled"];
    self.checkForUpdates = [defaults boolForKey:@"checkForUpdates"];
}

#pragma mark - Setters

- (void)setFrameSkip:(NSInteger)frameSkip {
    _frameSkip = frameSkip;
    preferences.frameSkip = frameSkip;
    [[NSUserDefaults standardUserDefaults] setInteger:frameSkip forKey:@"frameSkip"];
}

- (void)setScaled:(BOOL)scaled {
    _scaled = scaled;
    preferences.scaled = scaled;
    [[NSUserDefaults standardUserDefaults] setBool:scaled forKey:@"scaled"];
}

- (void)setPortraitSkin:(NSInteger)portraitSkin {
    _portraitSkin = portraitSkin;
    preferences.selectedPortraitSkin = portraitSkin;
    [[NSUserDefaults standardUserDefaults] setInteger:portraitSkin forKey:@"portraitSkin"];
}

- (void)setLandscapeSkin:(NSInteger)landscapeSkin {
    _landscapeSkin = landscapeSkin;
    preferences.selectedLandscapeSkin = landscapeSkin;
    [[NSUserDefaults standardUserDefaults] setInteger:landscapeSkin forKey:@"landscapeSkin"];
}

- (void)setCheatsEnabled:(BOOL)cheatsEnabled {
    _cheatsEnabled = cheatsEnabled;
    preferences.cheating = cheatsEnabled;
    [[NSUserDefaults standardUserDefaults] setBool:cheatsEnabled forKey:@"cheatsEnabled"];
}

- (void)setAutoSave:(BOOL)autoSave {
    _autoSave = autoSave;
    [[NSUserDefaults standardUserDefaults] setBool:autoSave forKey:@"autoSave"];
    
    // Don't set preferences.autoSave because GBA4iOS' auto save implementation is different.
}

- (void)setCheckForUpdates:(BOOL)checkForUpdates {
    _checkForUpdates = checkForUpdates;
    [[NSUserDefaults standardUserDefaults] setBool:checkForUpdates forKey:@"checkForUpdates"];
}

// Add your custom methods here

@end
