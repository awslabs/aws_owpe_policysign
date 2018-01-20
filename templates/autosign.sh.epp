#!/bin/sh

# If we do not have aws cli or jq, exit with error immediately
which aws > /dev/null 2>&1 || exit 2
which jq > /dev/null 2>&1 || exit 3

usage()
{
  echo "$0 [private dns name of ec2 instance]"
  exit 1
}

[ $# -eq 1 ] || usage

clientname=$1
# Criteria 1: the puppet client must be visible in my VPC
[ `aws ec2 describe-instances --filters "Name=private-dns-name,Values=$clientname" --output=text | wc -l | sed 's/ //g'` -eq 0 ] && exit 1

# Criteria 2: the puppet client must have proper tags
UNIQUETAG="puppetclient"
INSTANCEID=`aws ec2 describe-instances --filters "Name=private-dns-name,Values=$clientname" --output=json | jq .Reservations[].Instances[].InstanceId`
[ "`aws ec2 describe-tags --filters "Name=resource-id,Values=$INSTANCEID" --output json  | jq '.Tags[] | select(.Key=="myuniquetag").Value' | sed 's/"//g'`" != "$UNIQUETAG" ] && exit 1

# We passed everything, give it a thumbs up
exit 0
