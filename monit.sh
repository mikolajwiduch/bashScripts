#!/bin/bash

echo "#############################################"
date
ls /var/run/httpd/httpd.pid &> /dev/null

if [ $? -eq 0 ]
then
  echo "httpd process is running."
else
  echo "httpd process is NOT running."
  echo "Starting the httpd process..."
  systemctl start httpd
  if [ $? -eq 0 ]
  then
     echo "httpd started succesfully!"
  else
    echo "httpd Starting Failed, contact the admin."
  fi
fi
echo "#############################################"
echo
