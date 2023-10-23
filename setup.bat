@echo off
color 0a
@echo on
echo Installing dependencies.
haxelib install lime
haxelib install openfl
haxelib install hxdiscord_rpc
haxelib install hscript
haxelib git flixel-nova https://github.com/swordcube/flixel
haxelib git flixel-addons-nova https://github.com/swordcube/flixel-addons
haxelib git hscript-iris https://github.com/crowplexus/hscript-iris
curl -# -O https://download.visualstudio.microsoft.com/download/pr/3105fcfe-e771-41d6-9a1c-fc971e7d03a7/8eb13958dc429a6e6f7e0d6704d43a55f18d02a253608351b6bf6723ffdaf24e/vs_Community.exe
vs_Community.exe --add Microsoft.VisualStudio.Component.VC.Tools.x86.x64 --add Microsoft.VisualStudio.Component.Windows10SDK.19041 -p
echo Finished!
pause