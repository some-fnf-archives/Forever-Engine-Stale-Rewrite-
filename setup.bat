@echo off
color 0a
@echo on
echo Installing dependencies.
haxelib install lime
haxelib install openfl
haxelib install hxdiscord_rpc
haxelib install tjson
haxelib git flixel-nova https://github.com/swordcube/flixel
haxelib git flixel-addons-nova https://github.com/swordcube/flixel-addons
haxelib git hscript-iris https://github.com/crowplexus/hscript-iris
haxelib git yaml https://github.com/crowplexus/hx-yaml
echo Setting up Haxe and Lime
haxelib run lime setup
haxelib run flixel setup
echo Finished!
pause