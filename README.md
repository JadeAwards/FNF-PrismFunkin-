# Prism Funkin'

This is the repository for Prism Funkin', an engine for Friday Night Funkin' with QOL features while keeping it as vanilla as possible.

[Discord Server](https://discord.gg/GekwXk5DXZ)

# Features

- Options Menu (Keybind Presets, Downscroll, Antialiasing, etc.)
- JSON Modcharts
- Performance Improvements
- Clean and Readable Code
- And Much More!

## Build Instructions

*These can be found in art/ folder. You also need to install Haxe 4.2.5 and Git!*

**Windows:**
1. Run **windows.bat**.
2. Run **windows-msvc.bat**.
3. Run *lime test windows* in CMD.

**Linux:**
- *W.I.P*

**Mac:**
- *W.I.P*

## Modding Instructions

*Most of the modding requires you to have some experience with using source code as this engine is hardcode-dominant with some softcoding features. I plan to make a proper mod folder in the future, but until then this'll do. ALL THE MODDING FEATURES REQUIRE A COMPILED DEBUG BUILD TO ACCESS THEM!*

**Characters (Story Mode):** *FOR CUSTOM CHARACTERS, YOU'LL NEED TO GO INTO CHARACTER.HX AND MANUALLY CODE IN THE SPRITE AND POSES!*
1. Go to *Story Mode*.
2. Press 7, it should flash the screen (*if Flashing option is turned ON*) and debug text should appear.
3. Edit the positioning and scale of the Story Mode characters.
4. Once you do that, press "," and in the terminal it should show the character name, position, and scale. Now you're able to get accurate positions for your Story Mode character!

**Songs (Freeplay):**
1. Go to *assets/data/* folder.
2. Open up *freeplaySonglist.txt*.
3. Add in your song (*it can go anywhere in the file*).
4. Save it and your song will be in Freeplay!

**Characters:** *FOR CUSTOM CHARACTERS, YOU'LL NEED TO GO INTO CHARACTER.HX AND MANUALLY CODE IN THE SPRITE AND POSES!*
1. Go to any song (*make sure the character is in the song via Chart Editor*).
2. Either press 1, 2, or 3 to go into the Animation Debug (*1 = Dad, 2 = BF, 3 = GF*).
3. Edit the positioning of the poses.
4. Press ",", go to *assets/images/characters/offsets* and put the .json file there. Now your character is fully implemented!

## Credits

- [JadeAwards](https://bsky.app/profile/jadeawards.bsky.social) - Prism Funkin' Manager/Programmer
- [ninjamuffin99](https://twitter.com/ninja_muffin99) - Funkin' Programmer
- [PhantomArcade3K](https://twitter.com/phantomarcade3k) & [Evilsk8r](https://twitter.com/evilsk8r) - Funkin' Art
- [Kawai Sprite](https://twitter.com/kawaisprite) - Funkin' Musician
- [Psych Engine](https://github.com/ShadowMario/FNF-PsychEngine), [Forever Engine](https://github.com/SomeKitten/Forever-Engine) & [FPS Plus](https://github.com/ThatRozebudDude/FPS-Plus-Public) - BIG Prism Funkin' Inspiration

This engine was made with love to Friday Night Funkin' and it's community. <3
