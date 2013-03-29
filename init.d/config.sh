#!/bin/bash

JAVA_HOME=/usr/lib/jvm/java

EC2_HOME=/usr/local/ec2-api-tools
EC2_AMITOOL_HOME=/usr/local/ec2-ami-tools
EC2_URL=http://ec2.ap-northeast-1.amazonaws.com

AWS_EMR_HOME=/usr/local/elastic-mapreduce-cli
AWS_IAM_HOME=/usr/local/iamtool
AWS_RDS_HOME=/usr/local/rdstool
AWS_CLOUDWATCH_HOME=/usr/local/CloudWatch
AWS_CREDENTIAL_FILE=/home/xxx/.ssh/.aws_credential

AWS_ACCESS_KEY=yyyyy
AWS_SECRET_KEY=zzzzzzzzzzzzzzzzzzz

# env setting
export PATH=$PATH:$EC2_HOME/bin:$EC2_AMITOOL_HOME/bin:$AWS_RDS_HOME/bin:$AWS_IAM_HOME/bin:$AWS_EMR_HOME:$JAVA_HOME/bin:$AWS_CLOUDWATCH_HOME/bin

export JAVA_HOME
export EC2_HOME EC2_AMITOOL_HOME EC2_URL
export AWS_EMR_HOME AWS_IAM_HOME AWS_RDS_HOME AWS_CLOUDWATCH_HOME
export AWS_ACCESS_KEY
export AWS_SECRET_KEY
export AWS_CREDENTIAL_FILE
