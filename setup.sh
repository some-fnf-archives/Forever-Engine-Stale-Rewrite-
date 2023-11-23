#!bin/sh
echo Installing dependencies.
haxelib install lime
haxelib install openfl
haxelib install flixel
haxelib install flixel-addons
haxelib install hxdiscord_rpc
haxelib git flixel-arwen https://github.com/crowplexus/flixel
haxelib git flixel-addons-arwen https://github.com/crowplexus/flixel-addons
haxelib git hscript-iris https://github.com/crowplexus/hscript-iris
haxelib git yaml https://github.com/crowplexus/hx-yaml
echo Setting up Lime
haxelib run lime setup
echo Done!
