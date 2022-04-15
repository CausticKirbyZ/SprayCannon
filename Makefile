.SILENT:

all:
	echo "Building tools...."
	crystal build -p src/spdb.cr 
	crystal build -p src/spraycannon.cr 
	echo "Building supporting documents"
	help2man ./spraycannon  > spraycannon.1
	if [ -f spraycannon.1.gz ]; then rm spraycannon.1.gz; fi 
	gzip spraycannon.1
	echo "DONE BUILDING (to install run 'make install' )"

init: 
	echo "Fetching libs..."
	shards install


spraycannon: 
	crystal build -p src/spraycannon.cr 

spdb:
	crystal build -p src/spdb.cr 

spdb2:
	crystal build -p src/spdb.cr 

debug: 
	crystal build -p src/spraycannon.cr --debug
	crystal build -p src/spdb.cr --debug 
	crystal build -p src/spdb2.cr --debug 


install:
	echo "Installing Tools"
	mv ./spraycannon /usr/bin/spraycannon
	mv ./spdb /usr/bin/spdb
	echo "Installing man files"
	mv ./spraycannon.1.gz /usr/share/man/man1/
	echo "Tools Installed"
	echo "If you use the fish shell( the best shell ;) ) you should run fish_update_completions now"

uninstall: 
	echo "Uninstalling tools..."
	rm /usr/bin/spraycannon
	rm /usr/bin/spdb 
	rm /usr/share/man/man1/spraycannon.1.gz
	echo "SprayCannon and spdb uninstalled!"

clean: 
	rm -rf lib/
	if [ -f spdb ]; then rm spdb; fi 
	if [ -f spray.db ]; then rm spray.db; fi 
	if [ -f spraycannon ]; then rm spraycannon; fi 
	if [ -f spraycannon.1 ]; then rm spraycannon.1; fi 
	if [ -f spraycannon.1.gz ]; then rm spraycannon.1.gz; fi 
	if [ -f shard.lock ]; then rm shard.lock; fi 
