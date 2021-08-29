In case you have not created a git repository then it is a good idea to make a copy of your configuration file:
```bash
cp $dir/install-config.yaml $dir/install-config.yaml.$( date +%F_%H%M )
```
Now you can create the cluster in AWS:
```BASH
openshift-install-$version create cluster --dir $dir --log-level debug
```
The installation process will eventually finish successfully.

To access the cluster as the system:admin user when using 'oc', run the following command:
```bash
export KUBECONFIG=$dir/auth/kubeconfig
```
