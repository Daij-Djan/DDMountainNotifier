#About
this project providers a <b>commandline tool and a growl plugin</b> to send notifications with a <b>configurable icon</b> (psd,jpg,pdf,icns) to the <b>mountain lion notification center</b> and specify an app/file path or url to open on click!
Apart from this tool, this repository holds a plugin for the growl app that forwards ANY growl notification to the ML notification center (the click handling will not be perfect here because _I_ dont need it but it could easily be added)

##example usage
the CLI tool included can be called from a shellscript, applescript or cocoa. Find some examples attached. (later on ;))

##additional growl 1.3 plugin
I included a plugin for growl 1.3 (current appstore version) which sends ANY growl notification to the ML notification center.

With Growl running double click the MountianGrowlPlugin.growlView file to install it and enable it in growl's preferences so all notifications go the notification area (later on ;))

##everything prebuilt as well
The folder \_\_DIST__ has all the content built for 10.8

##Licenses
- Growl is originally from growl.info and is available under BSD
- DDMinizip is available under the original libz license