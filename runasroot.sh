#!/bin/bash

# Check if root is running this script

if [ "`id -u`" -ne 0 ]
then
    echo -e "\n\nThis script can only be run as root.\n\n"
    exit -1
fi
echo "This script has been run as root."