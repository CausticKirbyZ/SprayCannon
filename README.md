# Why
I got sick and tired of having to spray a password every 30-60 min for my userlist. I also would add to a userlist as an engagement went. While i added users they would not have all the old password guesses that the old users did. So i created....

<br>
<img src="./mdassets/spraycannon_art.png"> 


# SprayCannon
A fast password spray tool designed to simplify and automate many password spraying problems i faced. 
## Features 
* Database to keep track of what has been sprayed/valid finds (Sqlite3)
* Supports username,password (as single inputs and files )
* Jitter between individual authenticaion requests 
* Delay between passwords 
* MFA detection ( on a per module basis )
* Lockout detection (on a per module basis )
* Teams webhook support

## Current supported spray types 
|Type|MFA support| lockout detection | fully implemented |
|----|-----------|-------------------|-------------------|
ExchangeEAS|no  |  no               | yes
SonicwallVirtualOffice|no  |  no    | yes (no mfa though) 
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





# spdb
spdb is a simple applicaion to interact with the backend db for SprayCannon. 

interactive commands: 
* usernames - show usernames in the database
* passwords - show what passwords have been sprayed 
* sprayed - shows all username/password combination that have been sprayed
* vaid - shows all username/password combinations that are valid









# On the backs of Giants 
### None of the above would have been possible if not for the previous work done by: 
* @dafthack - [mailsniper](https://github.com/dafthack/MailSniper)/[MSOLSpray](https://github.com/dafthack/MSOLSpray)
* @byt3bl33d3r - [CrackMapExec](https://github.com/byt3bl33d3r/CrackMapExec) (inspiration for spdb)

## Thank you all for your inspiration and contributions to the community
