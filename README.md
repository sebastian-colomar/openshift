# How to install Red Hat Openshift Container Platform in AWS:

First go through the initial setup:
- [Initial Setup](install/initial.md)

Once finished run the following commands in your Cloud9 environment. 
First customize your environment variables:
```
GITHUB_BRANCH=master
GITHUB_REPOSITORY=openshift
GITHUB_USERNAME=academiaonline-org
GITHUB_LOCATION=${RANDOM}
```
Now you can clone the remote repository:
```
git clone --branch ${GITHUB_BRANCH} --single-branch -- https://github.com/academiaonline/openshift ${GITHUB_LOCATION}
cd ${GITHUB_LOCATION}/install/
```
Edit your environment file:
```
vi 00-env.sh
```
Now you can launch the script to create the cluster:
```
source ocp-aws-install.sh
```
