all:
	crystal build -p src/spdb.cr 
	crystal build -p src/spraycannon.cr 

SprayCannon: 
	crystal build -p src/spraycannon.cr 

spdb:
	crystal build -p src/spdb.cr 

