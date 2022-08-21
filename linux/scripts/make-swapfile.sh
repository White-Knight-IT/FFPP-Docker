#!/bin/bash

echo "Checking if swapfile already exists: "
echo " "
sudo swapon --show
echo " "
echo "Do you see a swapfile in the above output? [Y/n]: "
read inputVar
if [ $inputVar = "y" ]||[ $inputVar = "Y" ]
then
  echo "Cancelling swapfile creation"
  exit 0
else
  echo "Proceeding to create swapfile"
fi
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
echo " "
echo "Swapfile created and added to /etc/fstab"
