#!/bin/sh

echo "***********************************************************************"
echo "This script is not intended to be run manually but by Azure deployment."
echo "***********************************************************************"

# This script installs Docker, Docker-compose and the required tools to run quickstart on an Azure
# Ubuntu LTS VM. It then automatically runs the private network and make the explorer available
# from the outside on port 80 as well as RPC and WS endpoints.

# Check if user argument is present
if [ -z "$1" ]
then
  echo "No user name argument supplied."
  exit 1
fi

USER=$1

# Check if the user is registered in the system
id -u $USER > /dev/null 2>&1
if [ $? -eq 1 ]
then
  echo "No \"${USER}\" user registered on this system."
  exit 1
fi

PORT=80

# Check if port PORT is available before installing all this
sudo lsof -Pi :$PORT -sTCP:LISTEN -t > /dev/null 2>&1
if [ $? -eq 0 ]
then
  echo "Port ${PORT} is already in use on this system."
  exit 1
fi

# Update and install Docker pre requisites
sudo apt-get update
sudo apt-get install -y \
  apt-transport-https \
  ca-certificates \
  curl \
  software-properties-common

# Add Docker repository and gpg key and install Docker CE
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update
sudo apt-get install -y docker-ce

# Set Docker to start automatically and start it
sudo systemctl enable docker
sudo systemctl start docker

# Enable user to use Docker
sudo usermod -aG docker $USER

# Install Docker compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.23.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Go to user home, clone quickstart project and run it to be available on port 80 of the machine.
cd /home/$USER
git clone https://github.com/PegaSysEng/besu-quickstart.git
cd besu-quickstart
sudo ./run.sh -p $PORT
