#!/bin/bash
"#!/bin/bash\n",
"export PATH=$PATH:/usr/local/bin\n",
"yum update -y\n",
"yum install -y httpd24 php70 mysql56-server php70-mysqlnd gcc openssl-devel* nmap\n",
"service httpd start\n",
"export LOCAL_HOST=`curl http://169.254.169.254/latest/meta-data/local-hostname`\n",
"wget -O /home/ec2-user/install https://d1wk0tztpsntt1.cloudfront.net/linux/latest/install\n",
"chmod +x /home/ec2-user/install\n",
"bash /home/ec2-user/install -u false\n"

#while [ $(aws guardduty list-detectors --region ${target_region} --output table | wc -l) -le 3 ]; do  
#    echo waiting;
#    sleep 1; 
#done
#
#while [ $(aws ec2 describe-instances --region ${target_region} --filters "Name=tag:Type,Values=Malicious Instance" "Name=instance-state-name,Values=running" --query "Reservations[0].Instances[0].PublicIpAddress" | tr -d \\\") == "null" ]; 
#    do sleep 1; 
#done
#
#TARGET_IP=$(aws ec2 describe-instances --region ${target_region} --filters "Name=tag:Type,Values=Malicious Instance" "Name=instance-state-name,Values=running" --query "Reservations[0].Instances[0].PublicIpAddress" | tr -d \\\")
#while true; do 
#    curl $$TARGET_IP; 
#    sleep 15; 
#done