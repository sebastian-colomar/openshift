cp $dir/install-config.yaml $dir/install-config.yaml.$( date +%F_%H%M )

openshift-install-$version create cluster --dir $dir --log-level debug

export KUBECONFIG=$dir/auth/kubeconfig


