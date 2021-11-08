# How to install Red Hat Openshift Container Platform in AWS:

First go through the initial setup:
- [Initial Setup](install/initial.md)

Once finished run the following commands in your Cloud9 environment. 
First customize your environment variables:
```
github_branch=master
github_repository=openshift
github_username=academiaonline-org
github_location=${github_repository}-$( date +%s )
```
Now you can clone the remote repository:
```
git clone --branch ${github_branch} --single-branch -- https://github.com/academiaonline/openshift ${github_location}
cd ${github_location}/install/
```
Edit your environment file:
```
vi 00-env.sh
```
Now you can launch the script to create the cluster:
```
source ocp-aws-install.sh
```
