# How to install Red Hat Openshift Container Platform in AWS:

First go through the initial setup:
- [Initial Setup](install/initial.md)

Once finished run the following commands in your Linux terminal.

You need to run a BASH shell. You can do it as root or as a normal user:
```
sudo su --login root

```
Check that you have the necessary AWS credentials available:
```
aws configure

```
Now you can customize your environment variables:
```
github_branch=master
github_repository=openshift
github_username=sebastian-colomar
github_location=${HOME}/${github_repository}-$( date +%s )

```
Install git and docker if not yet available:
```
sudo yum install -y docker git
sudo systemctl enable --now docker

```
Now you can clone the remote repository:
```
git clone --branch ${github_branch} --single-branch -- https://github.com/${github_username}/${github_repository} ${github_location}
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
