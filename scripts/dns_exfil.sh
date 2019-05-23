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

function dns_exfil {

QUERY_LIST_PATH=$1/domains
if [[ -d "$QUERY_LIST_PATH" ]]; then 
# 5 - DNS Exfiltation
echo '***********************************************************************'
echo '* Test #5 - DNS Exfiltration                                          *'
echo '* A common exfiltration technique is to tunnel data out over DNS      *'
echo '* to a fake domain.  Its an effective technique because most hosts    *'
echo '* have outbound DNS ports open.  This test wont exfiltrate any data,  *'
echo '* but it will generate enough unusual DNS activity to trigger the     *'
echo '* detection.                                                          *'
echo '***********************************************************************'
echo
echo "Calling large numbers of large domains to simulate tunneling via DNS"
dig -f $QUERY_LIST_PATH/queries.txt > /dev/null &
echo 'Test 5: DNS Exfiltration'
echo 'Expected Finding: EC2 instance ' $RED_TEAM_INSTANCE ' is attempting to query domain names that resemble exfiltrated data'
echo 'Finding Type : Backdoor:EC2/DNSDataExfiltration'

else
  echo "ERROR: required file "$QUERY_LIST_PATH"/queries.txt does not exist"
fi

}
