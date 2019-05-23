#Copyright 2017 Amazon.com, Inc. or its affiliates. All Rights Reserved.
#
#  Licensed under the Apache License, Version 2.0 (the "License").
#  You may not use this file except in compliance with the License.
#  A copy of the License is located at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  or in the "license" file accompanying this file. This file is distributed
#  on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
#  express or implied. See the License for the specific language governing
#  permissions and limitations under the License.

#!/bin/bash

function ssh_bruteforce {

KEYS_PATH=$1/compromised_keys

if [[ -d "$KEYS_PATH" ]]; then 

# simulate external recon
#echo 'External port probe on a temporarily unprotected port'
# 2 - ssh brute force with list of keys found on web
echo '***********************************************************************'
echo '* Test #2 - SSH Brute Force with Compromised Keys                     *'
echo '* This simulates an SSH brute force attack on an SSH port that we    *'
echo '* can access from this instance. It uses (phony) compromised keys in  *'
echo '* many subsequent attempts to see if one works. This is a common      *'
echo '* techique where the bad actors will harvest keys from the web in     *'
echo '* places like source code repositories where people accidentally leave*'
echo '* keys and credentials (This attempt will not actually succeed in     *'
echo '* obtaining access to the target linux instance in this subnet)       *'
echo '***********************************************************************'
echo
for j in `seq 1 10`;
do
	sudo ./crowbar/crowbar.py -b sshkey -s $BASIC_LINUX_TARGET/32 -u ec2-user -k $KEYS_PATH;
done
echo
echo '-----------------------------------------------------------------------'
echo
echo 'Test 2: SSH Brute Force with Compromised Keys'
echo 'Expecting two findings - one for the outbound and one for the inbound detection'
echo 'Outbound: ' $RED_TEAM_INSTANCE ' is performing SSH brute force attacks against ' $BASIC_LINUX_TARGET
echo 'Inbound: ' $RED_TEAM_IP ' is performing SSH brute force attacks against ' $BASIC_LINUX_INSTANCE
echo 'Finding Type: UnauthorizedAccess:EC2/SSHBruteForce'
echo

else
  echo "ERROR: required dir "$KEYS_PATH" does not exist"
fi

}
