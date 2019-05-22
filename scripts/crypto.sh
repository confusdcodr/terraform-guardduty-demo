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

# 4 - CryptoCurrency Activity
echo '***********************************************************************'
echo '* Test #4 - CryptoCurrency Mining Activity                            *'
echo '* This simulates interaction with a cryptocurrency mining pool which *'
echo '* can be an indication of an instance compromise. In this case, we are*'
echo '* only interacting with the URL of the pool, but not downloading      *'
echo '* any files. This will trigger a threat intel based detection.        *'
echo '***********************************************************************'
echo
echo "Calling bitcoin wallets to download mining toolkits"
curl -s http://com.minergate.pool/dkjdjkjdlsajdkljalsskajdksakjdksajkllalkdjsalkjdsalkjdlkasj  > /dev/null &
curl -s http://xdn-xmr.pool.minergate.com/dhdhjkhdjkhdjkhajkhdjskahhjkhjkahdsjkakjasdhkjahdjk  > /dev/null &
echo
echo '-----------------------------------------------------------------------'
echo 'Test 4: Cryptocurrency Activity'
echo 'Expected Finding: EC2 Instance ' $RED_TEAM_INSTANCE ' is querying a domain name that is associated with bitcoin activity'
echo 'Finding Type : CryptoCurrency:EC2/BitcoinTool.B!DNS'
echo
