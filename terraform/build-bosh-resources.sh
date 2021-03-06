#!/bin/bash -e

usage ()
{
    cat << EOF
Usage: $0 options

OPTIONS:
    -p: GCP Project

EOF
}

while getopts ":p:" OPTION
do
    case ${OPTION} in
        p)
            GCP_PROJECT=${OPTARG}
            ;;
        ?)
            usage
            exit 1
            ;;
    esac
done


if [ -z ${GCP_PROJECT} ]
then
    usage
    exit 1
fi

source ../properties/gcp.properties

echo "==========================================================="
echo " Displaying Terraform Plan"
echo "==========================================================="

export GOOGLE_CREDENTIALS=$(cat ../${GCP_SERVICE_ACCOUNT}.key.json)

docker run -i -t \
  -e "GOOGLE_CREDENTIALS=${GOOGLE_CREDENTIALS}" \
  -v `pwd`/bosh-resources:/$(basename `pwd`) \
  -w /$(basename `pwd`) \
  hashicorp/terraform:light plan \
    -var service_account_email="${GCP_SERVICE_ACCOUNT}@${GCP_PROJECT}.iam.gserviceaccount.com" \
    -var projectid=${GCP_PROJECT} \
    -var region=${GCP_REGION} \
    -var zone=${GCP_ZONE} \
    -var baseip=${GCP_BASE_IP} \
    -var bosh_cli_version=${BOSH_CLI_VERSION}

docker run -i -t \
  -e "GOOGLE_CREDENTIALS=${GOOGLE_CREDENTIALS}" \
  -v `pwd`/bosh-resources:/$(basename `pwd`) \
  -w /$(basename `pwd`) \
  hashicorp/terraform:light apply \
    -var service_account_email="${GCP_SERVICE_ACCOUNT}@${GCP_PROJECT}.iam.gserviceaccount.com" \
    -var projectid=${GCP_PROJECT} \
    -var region=${GCP_REGION} \
    -var zone=${GCP_ZONE} \
    -var baseip=${GCP_BASE_IP} \
    -var bosh_cli_version=${BOSH_CLI_VERSION}

echo "==========================================================="
echo " FINISHED "
echo "==========================================================="
echo " Please wait a few minutes for the bosh-bastion to provision."
