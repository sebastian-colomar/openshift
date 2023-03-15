In order to install a new Red Hat Openshift cluster in AWS please follow these steps in the precise order.

You will need the Pull Secret generated in this page:
* https://cloud.redhat.com/openshift/install

Using a pull secret from the Red Hat OpenShift Cluster Manager is not required. You can use the following pull secret when prompted during the installation:
```
{"auths":{"fake":{"auth":"aWQ6cGFzcwo="}}}
```

If you do not use the pull secret from the Red Hat OpenShift Cluster Manager:
- Red Hat Operators are not available.
- The Telemetry and Insights operators do not send data to Red Hat.
- Content from the Red Hat Ecosystem Catalog Container images registry, such as image streams and Operators, are not available.

You will need to obtain a valid public domain name before installing the cluster:
* https://console.aws.amazon.com/route53/home

All the steps will be performed from a Linux terminal (for example an EC2 instance) with enough AWS privileges (AdministratorAccess will work):

For this purpose you need to create a new Access Key in your AWS IAM Security Credentials and then configure the AWS credentials in your Linux terminal:
* https://console.aws.amazon.com/iam/home
```bash
aws configure
```
It is important to create a new user for each new cluster and not to share AWS access keys between multiple clusters.
Otherwise, there will be conflicts between the AWS resources in the different clusters.
