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

# 1 - simulate internal recon and attempted lateral movement
echo
echo '***********************************************************************'
echo '* Test #1 - Internal port scanning                                    *'
echo '* This simulates internal reconaissance by an internal actor or an   *'
echo '* external actor after an initial compromise. This is considered a    *'
echo '* low priority finding for GuardDuty because its not a clear indicator*'
echo '* of malicious intent on its own.                                     *'
echo '***********************************************************************'
echo
sudo nmap -sT $BASIC_LINUX_TARGET
echo
echo '-----------------------------------------------------------------------'
echo
echo '*****************************************************************************************************'
echo 'Expected GuardDuty Findings'
echo
echo 'Test 1: Internal Port Scanning'
echo 'Expected Finding: EC2 Instance ' $RED_TEAM_INSTANCE ' is performing outbound port scans against remote host.' $BASIC_LINUX_TARGET
echo 'Finding Type: Recon:EC2/Portscan'
