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


# Install AWS CLI tools for querying IP address of the provisioner
# Ideally use DNS, manually inserting for simplicity
apt-get update && apt-get install -y awscli
provisioner=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=ap-workshop-provisioner" --filters "Name=instance-state-name, Values=running" --query 'Reservations[0].Instances[0].PrivateIpAddress' --region us-east-1)
ip=$(echo $provisioner | sed "s/\"//g")
echo "provisioner ${ip}" >> /etc/hosts

# download cookbooks
mkdir -p /var/chef
cd /var/chef
curl -Ls https://github.com/gosuri/ap-workshop-cookbooks/blob/master/dist/cookbooks.tar.gz?raw=true | tar xz

cat > /var/chef/json_data.json <<EOF
{
  "serf": {
    "cluster":"${ip}"
 }
}
EOF

# run chef for 3 times before failing
n=0
until [ $n -ge 3 ]; do
  chef-solo -o 'runtime' -j /var/chef/json_data.json && break
  n=$[$n+1]
  sleep 5
done
