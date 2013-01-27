GBA4iOS
=======

A fast GBA emulator for the iPhone/iPod Touch based on version 1.8.0 of gpSPhone by zodttd (https://github.com/zodttd/gpSphone). This version can be compiled directly in Xcode and deployed just like any other app. No jailbreak required.

__NEW IN VERSION 1.5 OF GBA4iOS__

* Can now rename ROMs! Tap and hold a ROM in the table view, and an alert will pop up to let you rename it to anything you want. Don't worry about it messing up your saves or save states, they'll all work just fine after the renaming. (Thanks Wrsford!)
* Auto Save. Did you ever accidentally lose your progress in a ROM due to something stupid like quitting the ROM by mistake or the app crashing? No need to worry! Now, whenever you load a save state, quit a ROM, or the app crashes, GBA4iOS will create an auto save state you can reload just like any other save state. You never have to worry about losing your progress again! (It can be turned off, but why would you want that?)
* Check For Updates. Tired of having to check Github or my Twitter feed (@iSkythe if you're wondering) to see if there are updates to GBA4iOS? A new option (enabled by default) checks to see if there are any updates on Github, and if so will show an alert detailing all the changes. Don't worry about it constantly checking though, it'll only check every 3 days.

__Version History__

_1.4_

* iPhone 5 Support - Enjoy those extra 112,640 pixels! (For real this time).
* Dramatically sped up the emulator. Now it is actually usable on iPhone 3GS and 4!
* ALPHA: Can now play Gameboy Color games. However, while it can load save files, it currently can't save to them. Also, only portrait orientation is supported, and there is no way to quit the ROM without quitting the app. But who cares, at least it works for now right?

_1.3_

* Simplified Xcode project - No need to compile a static library and the app, it's now all in one binary. It just works!

_1.2_

* App settings: tap the gear icon to change the frameskip, controller skins (including a new fullscreen landscape option), whether the emulated screen should be scaled to fit the iPhone’s screen or not. Cheats will be enabled in a future update.

* Can now open .zip files.

_1.1_

* Save state support. Simply tap the menu button while playing any game, and you can choose to save or load a save state from one of 5 slots.

* You can import save states (.svs) from other compatible emulators. Name them the exact name of the ROM you want it to be a save state for, and append the number slot you want for the save. For example, if you wanted to import a save state in the first slot for “Pokemon Emerald.GBA”, you would rename your .svs file “Pokemon Emerald0.svs”, and drag it into the Documents directory via iTunes File Sharing.

* Landscape support is now offered.

* Can now quit ROMs without quitting the app.



Differences in this version from gpSPhone available in the Cydia Store are:

* iTunes File Sharing support

* Works on non-jailbroken phones

However, some bugs do exist in the current version, such as:

* Audio sometimes will disappear for a second, and sometimes it'll completely disappear.

* Compatibility issues with some GBA games.

If you would like to contribute, I'd appreciate it! I'm trying to fix the current bugs, but any additional help is greatly appreciated. So send those pull requests :)

For all the latest news on GBA4iOS, SNES4iOS, or any of my other projects I'm working on, I'm @iSkythe on Twitter (http://twitter.com/iSkythe)

All that's left to say is enjoy playing your Pokémons and your Marios on your phone!
