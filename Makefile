all:
	shards install
	crystal build -p src/spdb.cr 
	crystal build -p src/spraycannon.cr 

SprayCannon: 
	crystal build -p src/spraycannon.cr 

spdb:
	crystal build -p src/spdb.cr 


install:
	echo "Building tools"
	shards install
	crystal build -p src/spdb.cr 
	crystal build -p src/spraycannon.cr 

	echo "Installing Tools"
	cp ./spraycannon /usr/bin/spraycannon
	cp ./spdb /usr/bin/spdb 
	echo "Tools Installed"

uninstall: 
	echo "Uninstalling tools..."
	rm /usr/bin/spraycannon
	rm /usr/bin/spdb 
	echo "SprayCannon and spdb uninstalled!"


