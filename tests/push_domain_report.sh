#!/bin/sh

today=`date +'%Y-%m-%d'`
start="2009-01-01"
port=4567
curl -s -S "$1:$port/scriptlet/domain_report?&start=$start&end=$today&push_to_s3=true"
