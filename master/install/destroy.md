In order to avoid highly expensive charges in AWS you should destroy the cluster after its use:
```BASH
openshift-install-$version destroy cluster --dir $dir --log-level debug
```
The uninstall process will eventually finish successfully.
