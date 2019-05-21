#!/bin/bash

# configure path
export PATH=$PATH:/usr/local/bin:/usr/sbin:/root/.local/bin
echo 'export PATH=/root/.local/bin:/usr/sbin:$PATH' >> /home/ec2-user/.profile

# install dependencies
yum update -y
yum install nmap git python python2-pip python-argparse gcc gcc-c++ glib2-devel -y
yum install cmake openssl-devel libX11-devel libXi-devel libXtst-devel libXinerama-devel -y
pip install paramiko

# get malicious
BasicLinuxTarget_PrivateIp=$(aws ec2 describe-instance) # flesh this out..
BasicWindowsTarget_PrivateIp=$(aws ec2 describe-instance) # flesh this out..

export privateIP=`curl http://169.254.169.254/latest/meta-data/local-ipv4`
curl -L https://raw.githubusercontent.com/awslabs/amazon-guardduty-tester/master/guardduty_tester.sh > /home/ec2-user/guardduty_tester.sh
mkdir /home/ec2-user/compromised_keys
mkdir /home/ec2-user/domains
mkdir /home/ec2-user/passwords
curl -L https://raw.githubusercontent.com/awslabs/amazon-guardduty-tester/master/artifacts/queries.txt > /home/ec2-user/domains/queries.txt
curl -L https://raw.githubusercontent.com/awslabs/amazon-guardduty-tester/master/artifacts/password_list.txt > /home/ec2-user/passwords/password_list.txt
curl -L https://raw.githubusercontent.com/awslabs/amazon-guardduty-tester/master/artifacts/never_used_sample_key.foo > /home/ec2-user/compromised_keys/compromised.pem
FILE="/home/ec2-user/compromised_keys/compromised.pem"
for FILE in {1..20}; do cp /home/ec2-user/compromised_keys/compromised.pem /home/ec2-user/compromised_keys/compromised$FILE.pem; done
echo 'BASIC_LINUX_TARGET="$BasicLinuxTarget_PrivateIp"' >> /home/ec2-user/localIps.sh
echo 'BASIC_WINDOWS_TARGET="$BasicWindowsTarget_PrivateIp"' >> /home/ec2-user/localIps.sh
echo -n 'RED_TEAM_INSTANCE="' >> /home/ec2-user/localIps.sh
wget -q -O - http://169.254.169.254/latest/meta-data/instance-id >> /home/ec2-user/localIps.sh
echo '"' >> /home/ec2-user/localIps.sh
echo -n 'RED_TEAM_IP="' >> /home/ec2-user/localIps.sh
wget -q -O - http://169.254.169.254/latest/meta-data/local-ipv4 >> /home/ec2-user/localIps.sh
echo '"' >> /home/ec2-user/localIps.sh
echo 'BASIC_LINUX_INSTANCE="$BasicLinuxTarget"' >> /home/ec2-user/localIps.sh
echo 'BASIC_WINDOWS_INSTANCE="$BasicWindowsTarget"' >> /home/ec2-user/localIps.sh

# install hydra
mkdir /home/ec2-user/thc-hydra
git clone -b "8.3" https://github.com/vanhauser-thc/thc-hydra /home/ec2-user/thc-hydra
cd /home/ec2-user/thc-hydra
/home/ec2-user/thc-hydra/configure
make
make install

# insetall FreeRDP
mkdir /home/ec2-user/FreeRDP
git clone git://github.com/FreeRDP/FreeRDP.git /home/ec2-user/FreeRDP
cd /home/ec2-user/FreeRDP
cmake -DCMAKE_BUILD_TYPE=Debug -DWITH_SSE2=ON .
make install
echo '/usr/local/lib/freerdp' >> /etc/ld.so.conf.d/freerdp.conf
ln -s /usr/local/bin/xfreerdp /usr/bin/xfreerdp

# install crowbar
cd /home/ec2-user
git clone https://github.com/galkan/crowbar /home/ec2-user/crowbar
chown -R ec2-user: /home/ec2-user
chmod +x /home/ec2-user/guardduty_tester.sh
chmod +x /home/ec2-user/crowbar/crowbar.py

# while [ $(aws guardduty list-detectors --region ${target_region} --output table | wc -l) -le 3 ]; do  
#     echo waiting; 
#     sleep 1; 
# done

# while [ $(aws ec2 describe-instances --region ${target_region} --filters "Name=tag:Type,Values=App Server" "Name=instance-state-name,Values=running" --query "Reservations[0].Instances[0].PublicIpAddress" | tr -d \\\") == "null" ]; do 
#     sleep 1; 
# done

# TARGET_IP=$(aws ec2 describe-instances --region ${target_region} --filters "Name=tag:Type,Values=App Server" "Name=instance-state-name,Values=running" --query "Reservations[0].Instances[0].PublicIpAddress" | tr -d \\\")
# while true; do 
#     ssh -o StrictHostKeyChecking=no -o PasswordAuthentication=no $$TARGET_IP; 
#     sleep 4; 
# done