#!/bin/bash

# Install chef solo
if [ ! -f "/usr/local/bin/chef-solo" ]; then
  export DEBIAN_FRONTEND=noninteractive
  # Upgrade headlessly (this is only safe-ish on vanilla systems)
  aptitude update &&
  apt-get -o Dpkg::Options::="--force-confnew" --force-yes -fuy dist-upgrade &&
  # Install Ruby and Chef
  aptitude install -y ruby1.9.1 ruby1.9.1-dev make &&
  sudo gem1.9.1 install --no-rdoc --no-ri chef --version 11.16.4
fi

# set hostname
echo "ap-workshop-provisioner" > /etc/hostname

# download cookbooks
mkdir -p /var/chef
cd /var/chef
curl -Ls https://github.com/gosuri/ap-workshop-cookbooks/blob/master/dist/cookbooks.tar.gz?raw=true | tar xz

# run chef for 3 times before failing
n=0
until [ $n -ge 3 ]; do
  chef-solo -o 'provisioner'  && break  # substitute your command here
  n=$[$n+1]
  sleep 5
done
