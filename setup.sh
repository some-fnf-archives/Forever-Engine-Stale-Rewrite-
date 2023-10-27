#!bin/sh
echo Installing dependencies.
haxelib install lime
haxelib install openfl
haxelib install hxdiscord_rpc
haxelib install tjson
haxelib git flixel-nova https://github.com/swordcube/flixel
haxelib git flixel-addons-nova https://github.com/swordcube/flixel-addons
haxelib git hscript-iris https://github.com/crowplexus/hscript-iris
haxelib git yaml https://github.com/crowplexus/hx-yaml
echo done.