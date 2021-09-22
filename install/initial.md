In order to install a new Red Hat Openshift cluster in AWS please follow these steps in the precise order.

You will need the Pull Secret generated in this page:
* https://cloud.redhat.com/openshift/install

All the steps will be performed from an AWS Cloud9 terminal with enough privileges (AdministratorAccess will work):
* https://ap-south-1.console.aws.amazon.com/cloud9/home
<!--
```bash
branch=master
domain=github.com
file=policy.yaml
path=etc/aws
project=openshift
username=secobau

location=$project/$path/$file

git clone --single-branch -b $branch https://$domain/$username/$project
aws cloudformation create-stack --stack-name ocp-${file%.yaml} --template-body file://$location --capabilities CAPABILITY_NAMED_IAM
rm -rf $project 
```
-->
You will need to obtain a valid public domain name before installing the cluster:
* https://console.aws.amazon.com/route53/home

Disable AWS managed temporary credentials in AWS Cloud9 settings. 

Now you need to create a new Access Key in your AWS IAM Security Credentials and then configure your AWS Cloud9 terminal:
* https://console.aws.amazon.com/iam/home
```bash
aws configure
```
