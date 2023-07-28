SHELL := /bin/bash # Use bash syntax

.SILENT:



CRYSTAL_VERSION := $(shell crystal --version 2>/dev/null)
SHARDS_VERSION  := $(shell shards  --version 2>/dev/null)

CRYSTAL_PROJECT_LIBS := ./lib


$(CRYSTAL_PROJECT_LIBS): | shard.yml
	echo -e "\033[0;33mFetching dependancy shards...\033[0m"
	shards install
	echo -e "\033[0;32mShards Installed\033[0m"


all: spraycannon spdb 
	echo -e "\033[0;32mAll Projects Built!:)\033[0m"

# all:
# 	if [ ! -d ./lib ]; then echo -e "\033[0;33mFetching libs...\033[0m" &&  shards install && 	echo -e "\033[0;32mDone!\033[0m"; fi 
# 	echo "Building tools:"
# 	echo -e "\033[0;33mBuilding spdb...\033[0m"
# 	crystal build -p src/spdb.cr 
# 	echo -e "\033[0;32mDone!\033[0m"
# 	echo -e "\033[0;33mBuilding spraycannon...\033[0m"
# 	crystal build -p src/spraycannon.cr 
# 	echo -e "\033[0;32mDone!\033[0m"
# 	echo -e "\033[0;33mBuilding supporting documents...\033[0m"
# 	help2man ./spraycannon  > spraycannon.1
# 	if [ -f spraycannon.1.gz ]; then rm spraycannon.1.gz; fi 
# 	gzip spraycannon.1
# 	echo -e "\033[0;32mDone!\033[0m"
# 	echo -e "\033[0;32mDONE BUILDING ( to install run 'make install' )\033[0m"


# init: 
# 	echo "Fetching libs..."
# 	shards install


spraycannon: $(shell find ./src -name '*.cr') | $(CRYSTAL_PROJECT_LIBS)
	echo -e "\033[0;33mBuilding spraycannon...\033[0m"
	if [ -f ./spraycannon ]; then rm ./spraycannon; fi 
	crystal build -p src/spraycannon.cr 
	echo -e "\033[0;32mDone!\033[0m"

spdb: $(shell find ./src -name '*.cr') | $(CRYSTAL_PROJECT_LIBS)
	echo -e "\033[0;33mBuilding spdb...\033[0m"
	if [ -f ./spdb ]; then rm ./spdb; fi 
	crystal build -p src/spdb.cr
	echo -e "\033[0;32mDone!\033[0m"

debug: 
	crystal build -p src/spraycannon.cr --debug
	crystal build -p src/spdb.cr --debug 



install: all 
	echo "Installing Tools"
	help2man ./spraycannon  > spraycannon.1
	gzip spraycannon.1
	mv ./spraycannon /usr/bin/spraycannon
	mv ./spdb /usr/bin/spdb
	echo "Installing man files"
	mv ./spraycannon.1.gz /usr/share/man/man1/
	echo "Tools Installed"
	echo "If you use the fish shell( the best shell ;) ) you should run fish_update_completions to add spraycannon autocomplete now"


uninstall: 
	echo "Uninstalling tools..."
	rm /usr/bin/spraycannon
	rm /usr/bin/spdb 
	rm /usr/share/man/man1/spraycannon.1.gz
	echo "SprayCannon and spdb uninstalled!"


clean: 
	rm -rf lib/
	if [ -f spdb ]; then rm spdb; fi 
	if [ -f spdb2 ]; then rm spdb2; fi 
	if [ -f spray.db ]; then rm spray.db; fi 
	if [ -f spraycannon ]; then rm spraycannon; fi 
	if [ -f spraycannon.1 ]; then rm spraycannon.1; fi 
	if [ -f spraycannon.1.gz ]; then rm spraycannon.1.gz; fi 
	if [ -f shard.lock ]; then rm shard.lock; fi 
	if [ -f exported_spdb_passwords.csv ]; then rm exported_spdb_passwords.csv; fi
	if [ -f exported_spdb_usernames.csv ]; then rm exported_spdb_usernames.csv; fi
	if [ -f exported_spdb_valid.csv ]; then rm exported_spdb_valid.csv; fi
	if [ -f exported_spdb_sprayed.csv ]; then rm exported_spdb_sprayed.csv; fi
