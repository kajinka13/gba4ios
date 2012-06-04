GBA4iOS
=======

A fast GBA emulator for the iPhone/iPod Touch based on version 1.8.0 of gpSPhone by zodttd (https://github.com/zodttd/gpSphone). This version can be compiled directly in Xcode and deployed just like any other app. No jailbreak required.

To edit, simply open the GBA4iOS.xcworkspace file. Inside will be two projects each with their own target: iGBA, which builds a static library (libiGBA.a), and GBA4iOS, which builds the GBA4iOS app (which uses libiGBA.a). Just build in Xcode and it will compile both iGBA and GBA4iOS for you.

NEW IN VERSION 1.2 OF GBA4iOS:

• App settings: tap the gear icon to change the frameskip, controller skins (including a new fullscreen landscape option), whether the emulated screen should be scaled to fit the iPhone’s screen or not. Cheats will be enabled in a future update.

• Can now open .zip files.

NEW IN VERSION 1.1 OF GBA4iOS:

•Save state support. Simply tap the menu button while playing any game, and you can choose to save or load a save state from one of 5 slots.

•You can import save states (.svs) from other compatible emulators. Name them the exact name of the ROM you want it to be a save state for, and append the number slot you want for the save. For example, if you wanted to import a save state in the first slot for “Pokemon Emerald.GBA”, you would rename your .svs file “Pokemon Emerald0.svs”, and drag it into the Documents directory via iTunes File Sharing.

•Landscape support is now offered.

•Can now quit ROMs without quitting the app.

Differences in this version from gpSPhone available in the Cydia Store are:

•iTunes File Sharing support

•Works on non-jailbroken phones

However, some bugs do exist in the current version, such as:

•Audio sometimes will disappear for a second, and sometimes it'll completely disappear.

•Compatibility issues with some GBA games.

Coming features:

•GBA4iOS Settings

If you would like to contribute, I'd appreciate it! I'm trying to fix the current bugs, but any additional help is greatly appreciated. So send those pull requests :)

All that's left to say is enjoy playing your Pokémons and your Marios on your phone!