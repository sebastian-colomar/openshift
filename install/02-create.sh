rm -f ${dir}/install-config.yaml.bak
cp ${dir}/install-config.yaml ${dir}/install-config.yaml.bak

openshift-install-${version} create cluster --dir ${dir} --log-level debug

export KUBECONFIG=${dir}/auth/kubeconfig

oc create secret generic htpass-secret --from-file=htpasswd=users.htpasswd -n openshift-config
oc apply -f oauth.yaml
oc adm policy add-cluster-role-to-user cluster-admin root
