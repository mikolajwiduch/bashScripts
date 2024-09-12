#!/bin/bash

#Variables Declaration
PACKAGE="httpd wget unzip"
SVC="httpd"
URL="### static website template ###"
ART_NAME="###"
TEMPDIR="/tmp/webfiles"

# Installing Dependencies
echo "########################"
echo "Installing packages. "
echo "########################"
sudo yum install $PACKAGE -y > /dev/null
echo

# Start & Enable Service
echo "########################"
echo "Start & Enable HTTPD Service"
echo "########################"
sudo systemctl start $SVC
sudo systemctl enable $SVC
echo
# Creating Temp Directory
echo "########################"
echo "Starting Artificat Deployment"
echo "########################"
mkdir -p $TEMPDIR
cd $TEMPDIR

echo

wget $URL > /dev/null
unzip $ART_NAME.zip > /dev/null
sudo cp -r $ART_NAME/* /var/www/html
echo

# Bounce Service
echo "########################"
echo "Restarting HTTPD Service"
echo "########################"
systemctl restart $SVC
echo

#Clean Up
echo "########################"
echo "Removing Temp Files"
echo "########################"
rm -rf $TEMPDIR
echo
echo "-----------------------"
echo "         DONE!         "
echo "-----------------------"
echo
sudo systemctl status $SVC
echo
ls /var/www/html
