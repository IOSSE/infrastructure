#!/bin/bash

echo $REPOSITORY								# URL to the Repository maybe .git or .zip
echo "${REPOPATH:=/html/}"			# Path for $BASEDIR on the Repository or first-level
echo "${BASEDIR:=html}"					# Publish on this directory on the webserver
echo "$AFTERCOPY"								# Bash script that will be run after copy action
echo "${USERID:=33}"						# User-ID of www-data user

# Set UID and Group
usermod -u $USERID www-data


# Check if files already exist in the target directory
if [ "$(ls -A /var/www/html)" ]; then
    echo "Files already exist in the target directory. The script will not be executed."
    apache2-foreground  # Start the Apache web server directly
    exit 0  # Exit the script
fi

# Check if the REPOSITORY variable is set
if [ -z "$REPOSITORY" ]; then
    echo "REPOSITORY is not defined. The script will not be executed."
    apache2-foreground  # Start the Apache web server directly
    exit 0  # Exit the script
fi

mkdir /var/www/html

wget -O repo.zip $REPOSITORY
unzip repo.zip -d repo

if [ $REPOPATH == "first-level" ]; then
	cd repo
	REPOPATH=/$(ls -d */ | head -n 1)
	cd ..
fi	

rm -r /var/www/html/*	
if [ $BASEDIR == "html" ]; then
	cp -r /root/repo$REPOPATH* /var/www/html
else
	cd /var/www/html
	# $BASEDIR mit cut aufteilen
	IFS='/' read -ra parts <<< "$(echo "$BASEDIR" | cut -d'/' -f2-)"

	# Iterieren über die Teile des aufgeteilten Strings
	for ((i=0; i<${#parts[@]}; i++)); do
		current_part="${parts[i]}"
		echo "$current_part"
		# Überprüfe, ob das aktuelle Teil das letzte ist
		if [ $i -eq $(( ${#parts[@]} - 1 )) ]; then
		  cp  -r /root/repo$REPOPATH $current_part
		  echo "<?php header(\"HTTP/1.1 303 See Other\");header(\"Location: $current_part/\"); ?>" > index.php
		else
		  mkdir $current_part
		  echo "<?php header(\"HTTP/1.1 303 See Other\");header(\"Location: $current_part/\"); ?>" > index.php
		  chmod a+rx index.php 
		  cd $current_part
		fi
	done
fi	
if [[ -n "$AFTERCOPY" ]]; then
	bash -c "$AFTERCOPY"
fi
chown -R www-data:www-data 	/var/www/html
apache2-foreground

