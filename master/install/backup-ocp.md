### How to backup your Openshift Container Platform:

In order to successfully run the following script you need to run it from a virtual machine INSIDE the VPC network of the OCP cluster and that contains in the `$HOME/.ssh` folder the SSH private key that pairs the SSH public key which was injected in the virtual machines of the cluster during the installation process.
```bash
for master in $( oc get node | awk /master/'{ print $1 }' )
do
  ssh core@$master 'mkdir backup; sudo -E /usr/local/bin/cluster-backup.sh backup'
done


```
