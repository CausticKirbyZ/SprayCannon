## spraycannon:1.0.6 / spdb:2.0.0
#### New Features
- spdb
    - version bump to 2.0.0
    - tab completion moved to mainline now. not experimental anymore 
    - search features for searching the database 
    - database stats summary 
- spraycannon 
    - updated database to support sparytype
#### Additional SprayTypes
#### Enhanced Features
- spdb  
    - spdb now uses tables
    - help menu updated 
#### Bug Fixes
#### Other
- added prebuilt release for Ubuntu
- added prebuilt release for Kali
- added prebuilt release for Debain




## 1.0.5
#### New Features
- added a couple options to makefile for building and installing experimental features
    - make experimental
    - make install-experimental
- currently this will install only the experimental version of spdb with tab completion. 
#### Additional SprayTypes
#### Enhanced Features
- o365 now alerts when valid accunt conditional access is found
#### Bug Fixes
- o365 spray not detecting valid accounts when conditional access is applied
- some spelling fixes 




## 1.0.4
#### New Features
- Theres a wiki now!

#### Additional SprayTypes
- VmWare Horizons

#### Enhanced Features
- Expiramental build of spdb as spdb2. With support for tab completion. 

#### Bug Fixes
- esxi was set to spray to "/" not the "/sdk" endpoint which handles the actual auth request. This is now mapped to /sdk and auth works with `-t 'https://esxi.ip.or.domain'`

---

## 1.0.3
#### New Features
- Theres actualy a release notes now...

#### Additional SprayTypes
- ESXI web page ( Tested v6.5, v7.0 )

#### Enhanced Features
- Better WebHook support. Not just teams anymore.
    Now supports:
    - Teams
    - Discord
    - Google
    - Slack

#### Bug Fixes



