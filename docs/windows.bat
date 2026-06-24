@echo off
color 0a
cd ..
@echo on
echo Installing dependencies...
echo This might take a few moments depending on your internet speed.
haxelib install actuate 1.9.0
haxelib install box2d 1.2.3
haxelib install flixel-addons 2.11.0
haxelib install flixel-tools 1.5.1
haxelib install flixel-ui 2.4.0
haxelib install flixel 4.11.0
haxelib install hscript 2.7.0
haxelib install hxcpp 4.3.2
haxelib install layout 1.2.1
haxelib install lime 7.9.0
haxelib install openfl 9.5.2
haxelib install systools 1.1.0
haxelib run lime setup
echo Finished!
pause