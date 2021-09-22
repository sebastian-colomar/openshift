# How to install Red Hat Openshift Container Platform in AWS:

First go through the initial setup:
- [Initial Setup](install/initial.md)

Once finished run the following commands in your Cloud9 environment:
```
git clone https://github.com/academiaonline/openshift
cd openshift/
git checkout master
cd install/
```
Edit your environment file:
```
vi 00-env.sh
```
Now you can launch the script to create the cluster:
```
source ocp-aws-install.sh
```
