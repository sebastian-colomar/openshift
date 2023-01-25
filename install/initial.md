In order to install a new Red Hat Openshift cluster in AWS please follow these steps in the precise order.

You will need the Pull Secret generated in this page:
* https://cloud.redhat.com/openshift/install

You will need to obtain a valid public domain name before installing the cluster:
* https://console.aws.amazon.com/route53/home

All the steps will be performed from a Linux terminal (I am using an EC2 instance) with enough AWS privileges (AdministratorAccess will work):

For this purpose you need to create a new Access Key in your AWS IAM Security Credentials and then configure the AWS credentials in your Linux terminal:
* https://console.aws.amazon.com/iam/home
```bash
aws configure
```
