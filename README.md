#About
this project providers a <b>commandline tool and a growl plugin</b> to send notifications with a <b>configurable icon</b> (psd,jpg,pdf,icns) to the <b>mountain lion notification center</b> and specify an app/file path or url to open on click!
Apart from this tool, this repository holds a plugin for the growl app that forwards ANY growl notification to the ML notification center (the click handling will not be perfect here because _I_ dont need it but it could easily be added)

##example usage
the CLI tool included can be called from terminal, from a shellscript or applescript or cocoa. For use in scripts it should be installed by copying the file to /usr/bin


e.g. from terminal, to have a notification seem to come from apple mail:		
	
	hostname:~ user$  MountainNotifier com.apple.mail 'New Mail' 'One new Mail by Dominik' 'The mail's body starts with: Hi, growl is cool!'
	
You pass the tool 4 Parameters:
- 1. the original caller: this can be an apple bundle identifier OR a unique string 'e.g. my super-tool', <b>This identifier is used by Apple to decide which category in the sidebar a notification gets placed into.</b>
- 2. you pass the notification's title: any string
- 3. you pass the notification's subtitle: any string 
- 4. you pass the notification's content. the message body: any string 
- 5. OPTIONALLY you can pass in the path or url of a icns file to be used for the notification and category icon. (<b>If not specified BUT caller is a bundle identifier, the bundle's icon is used</b>)

from an applescript you call it via 'do shellscript', in a shellscript the syntax is the same as in terminal and in cocoa you use the NSTask API to run it.

##additional growl 1.3 plugin
I included a plugin for growl 1.3 (current appstore version) which sends ANY growl notification to the ML notification center.

With Growl running double click the MountianGrowlPlugin.growlView file to install it and enable it in growl's preferences so all notifications go the notification area (later on ;))

##everything prebuilt as well
In the Downloads area there is all content built for 10.8. 
Nothing is code-signed though yet :)

##Licenses
- Growl is originally from growl.info and is available under BSD
- DDMinizip is available under the original libz license