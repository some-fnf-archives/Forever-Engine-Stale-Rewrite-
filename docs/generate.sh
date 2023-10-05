#! /bin/sh
cd ..
lime build linux -debug --haxeflag="-xml docs/doc.xml"
haxelib run dox -i docs -o docs/pages --title "Forever Engine Documentation" --include external --include funkin --include forever
