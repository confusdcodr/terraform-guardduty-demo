#
# script used to manage guard dutying findings
#
# To add a finding generation scirpt:
# 1. create the script and place it in the script folder. Ensure the logic of your script is callable with a single function
# 2. add the shorthand name of the script/test to the VULN_LIST array
# 3. add the VULN as an option to the if/else chain below 

#!/bin/bash -e

source ./*.sh

VULN_LIST=(
  "BACKDOOR"
  "CRYPTO"
  "DNS"
  "RDP"
  "RECON"
  "SSH"
)

ARTIFACTS_DIR=/home/ec2-user/artifacts

# https://stackoverflow.com/a/8574392/4254278

function containsElement () {
  local e match="$1"
  shift
  for e; do [[ "$e" == "$match" ]] && return 0; done
  return 1
}

# inspo https://gist.github.com/magnetikonline/0e44ab972a7efa3ac138

function usage {
	cat <<EOM
Usage: $(basename "$0") [OPTION]...

  -v VALUE    Run the specified guard dutying finding generation function

  -h          display help
EOM

	exit 2
}

# init switch flags
c=0
d=0

while getopts ":v:b:cdh" optKey; do
	case "$optKey" in
		v)
			VULN=$OPTARG
			;;
		b)
			b=$OPTARG
			;;
		c)
			c=1
			;;
		d)
			d=1
			;;
		h|*)
			usage
			;;
	esac
done

shift $((OPTIND - 1))

if ( containsElement "$VULN" "${VULN_LIST[@]}" ); then
  if [[ "$VULN" == "BACKDOOR" ]]; then
    backdoor
  elif [[ "$VULN" == "CRYPTO" ]]; then
    crypto
  elif [[ "$VULN" == "DNS" ]]; then
    dns_exfil "$ARTIFACTS_DIR"
  elif [[ "$VULN" == "RDP" ]]; then
    rdp_bruteforce "$ARTIFACTS_DIR"
  elif [[ "$VULN" == "RECON" ]]; then
    recon
  elif [[ "$VULN" == "SSH" ]]; then
    ssh_bruteforce "$ARTIFACTS_DIR"
  fi
else
	echo "Specified finding script $VULN does not exist"
fi
