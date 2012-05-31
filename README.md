GBA4iOS
=======

A fast GBA emulator for the iPhone/iPod Touch based on version 1.8.0 of gpSPhone by zodttd (https://github.com/zodttd/gpSphone). This version can be compiled directly in Xcode and deployed just like any other app. No jailbreak required.

To edit, simply open the GBA4iOS.xcworkspace file. Inside will be two projects each with their own target: iGBA, which builds a static library (libiGBA.a), and GBA4iOS, which builds the GBA4iOS app (which uses libiGBA.a). Just build in Xcode and it will compile both iGBA and GBA4iOS for you.

Differences in this version from gpSPhone available in the Cydia Store are:

•iTunes File Sharing support
•Works on non-jailbroken phones

However, some bugs do exist in the current version, such as:

•Audio sometimes will disappear for a second, and sometimes it'll completely disappear.
•Compatibility issues with some GBA games.

Coming features:

•GBA4iOS Settings
•Landscape mode
•Save states

If you would like to contribute, I'd appreciate it! I'm trying to fix the current bugs, but any additional help is greatly appreciated. So send those pull requests :)

All that's left to say is enjoy playing your Pokémons and your Marios on your phone!