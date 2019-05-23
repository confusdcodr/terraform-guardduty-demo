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

function backdoor {

# load IP addresses created by templates

echo
# 6 - Backdoor:EC2/C&CActivity.B!DNS
echo '***********************************************************************'
echo '* Test #6 - Fake domain to prove that GuardDuty is working            *'
echo '* This is a permanent fake domain that customers can use to prove that*'
echo '* GuardDuty is working.  Calling this domain will always generate the *'
echo '* Backdoor:EC2/C&CActivity.B!DNS finding type                         *'
echo '***********************************************************************'
echo
echo "Calling a well known fake domain that is used to generate a known finding"
dig GuardDutyC2ActivityB.com any
echo
echo '*****************************************************************************************************'
echo 'Expected GuardDuty Findings'
echo
echo 'Test 6: C&C Activity'
echo 'Expected Finding: EC2 instance ' $RED_TEAM_INSTANCE ' is querying a domain name associated with a known Command & Control server. '
echo 'Finding Type : Backdoor:EC2/C&CActivity.B!DNS'
echo

}
