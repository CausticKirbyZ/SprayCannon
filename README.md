# Why
I got sick and tired of having to manually spray a password every 30-60 min for my userlist and managing a larget list with what passwords for what was the worst. Also adding to a userlist as an engagement went. While i added users they would not have all the old password guesses that the old users did. So i created....

<br>
<img src="./mdassets/spraycannon_art.png"> 


# **SprayCannon**
A fast password spray tool designed to simplify and automate many password spraying problems i faced. 
## **Features**
* Database to keep track of what has been sprayed/valid finds (Sqlite3)
* Supports username,password (as single inputs and files )
* Jitter between individual authenticaion requests 
* Delay between passwords 
* MFA detection ( on a per module basis )
* Lockout detection (on a per module basis )
* Teams webhook support

## **Current supported spray types**
fully implemented means that the module works as designed. some protocols may not support mfa detection. others i have not had a chance to compare the "valid" check for one with MFA enabled ( ex. sonicall virtualoffice )
|Type|MFA support| lockout detection | fully implemented |
|----|-----------|-------------------|-------------------|
ExchangeEAS|no  |  no               | yes
SonicwallVirtualOffice|no  |  no    | yes (no mfa though) 
Sonicwall(the digest one) | no | no | yes
O365|YES|YES|yes
VPN Cisco|no|no|no
VPN Fortinet|no|no|kinda(use at own risk)

```
Global options:
    -s, --spray-type=[spraytype]     Set spray type. (o365, ExchageEAS, vpn_sonicwall_virtualoffice, vpn_sonicwall_digest, vpn_fortinet)
    -t, --target=[ip/hostname]       Target to spray
    -u, --username=[name]            Username or user txt file to spray from
    -p, --password=[password]        Target to spray
    -d, --delay=[time]               time in seconds to delay between password attempts
    -j, --jitter=[time]              time in milliseconds to delay between individual account attempts. default is 1000.
    --domain=[domain]                Sets the domain for options that require domain specification.
    -h, --help                       Print Help menu
    -v, --verbose                    Print verbose information
Additional Options:
    --nodb                           does not use the database
    --user-as-password               Sets the user and password to the same string
    --webhook=[url]                  Will send a teams webhook if valid credential is found!!

```


## **Use**
### Download from [releases](https://github.com/CausticKirbyZ/SprayCannon/releases). 
or 
### Compile yourself 
either use the make file 
```
make all 
```
or 
```
make spraycannon 
```
or
```
make spdb
```
### the manual way 
```
crystal build -p src/spraycannon.cr 
crystal build -p src/spdb.cr 
```
you can also use 
```
crystal build -p --no-debug --release  
```
which will take longer but will be more optimized (not that you need it) it also wont give you help if something breaks.... your choice 










## TODO
* multithread things ( templates started )
* add a spraygroup feature - so that you can spray multiple back to back but then delay. this may be usefull for some lockout policies. 
* go public
* add wiki
* maybe update the way some of the modules are called (thinking ./spraycannon \<type\> [arguments] ex. spraycannon vpncisco -u users.txt -p "Password123" )
* docker file? 
* make install feature 
* pipeline something so that i can build/release on multiple platforms at a time




## **Contributing**
* Fork the project and submit a request with your feature/fix 
* Submit a feature request through github(look at the wiki/todo list first your idea might already be there or answered)
* If you have a new spray type you want submit a feature request or give me the web request sequence (burp files are nice). NOTE if its not public/you cant prove you own something i wont test password spraying unless i can spin it up in my lab 





# **spdb**
spdb is a simple applicaion to interact with the backend db for SprayCannon. 

interactive commands: 
* usernames - show usernames in the database
* passwords - show what passwords have been sprayed 
* sprayed - shows all username/password combination that have been sprayed
* vaid - shows all username/password combinations that are valid









# **On the shoulders of Giants**
### None of the above would have been possible if not for the previous work done by: 
* @dafthack - [mailsniper](https://github.com/dafthack/MailSniper)/[MSOLSpray](https://github.com/dafthack/MSOLSpray)
* @byt3bl33d3r - [CrackMapExec](https://github.com/byt3bl33d3r/CrackMapExec)'s cmedb (inspiration for spdb)

# Thank you all for your inspiration and contributions to the community!!!  




### **Crystal Install help** 
---
For Arch based linux distros  
````
sudo pacman -S crystal shards 
````

**Debian/RedHat** based linux distros
```
curl -fsSL https://crystal-lang.org/install.sh | sudo bash
```

**Windows** (Crystal not fully supported on windows *yet*) there are several options:
* There is prerelease crystal compiler for windows that is available. 
* Use wsl
* use a linux vm 

\* **Note:** Crystal doesnt have an official windows compiler release yet. If a bug is found please create a bug report and i will try to address it. 

**MacOS**(homebrew):
```
brew update
brew install crystal
```

\* **Note:** I dont have a mac so i cant quite support MacOS. If a bug is found please create a bug report and i will try to fix. 

