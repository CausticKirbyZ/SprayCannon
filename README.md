# Why
I got sick and tired of having to spray a password every 30-60 min for my userlist. I also would add to a userlist as an engagement went. While i added users they would not have all the old password guesses that the old users did. So i created....
```
███████╗██████╗ ██████╗  █████╗ ██╗   ██╗ ██████╗ █████╗ ███╗   ██╗███╗   ██╗ ██████╗ ███╗   ██╗
██╔════╝██╔══██╗██╔══██╗██╔══██╗╚██╗ ██╔╝██╔════╝██╔══██╗████╗  ██║████╗  ██║██╔═══██╗████╗  ██║
███████╗██████╔╝██████╔╝███████║ ╚████╔╝ ██║     ███████║██╔██╗ ██║██╔██╗ ██║██║   ██║██╔██╗ ██║
╚════██║██╔═══╝ ██╔══██╗██╔══██║  ╚██╔╝  ██║     ██╔══██║██║╚██╗██║██║╚██╗██║██║   ██║██║╚██╗██║
███████║██║     ██║  ██║██║  ██║   ██║   ╚██████╗██║  ██║██║ ╚████║██║ ╚████║╚██████╔╝██║ ╚████║
╚══════╝╚═╝     ╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝    ╚═════╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝  ╚═══╝ ╚═════╝ ╚═╝  ╚═══╝
```                                
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







# SPDB
spdb is a simple applicaion to interact with the backend db for SprayCannon






# On the backs of Giants 
### None of the above would have been possible if not for the previous work done by: 
* @dafthack - mailsniper/msolspray
* @byt3bl33d3r - cme (inspiration for spdb)

##  Thank you for your inspiration 
