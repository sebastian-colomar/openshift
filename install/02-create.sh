cp ${dir}/install-config.yaml ${dir}/install-config.yaml.bak

openshift-install-${version} create cluster --dir ${dir} --log-level debug

export KUBECONFIG=${dir}/auth/kubeconfig


