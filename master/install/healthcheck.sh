#!/bin/sh

oc project default
oc get clusterversion
oc get infrastructure cluster -ojson|jq -r .status
oc get no -owide
oc get network cluster -o json|jq -r '.spec'
oc get proxy cluster -ojson|jq -r '.spec'
oc get csv -A|awk '($2 != "NAME"){print $2,$3,$4,$5,$6}'|sort -u|column -t
oc get co
oc get pv,pvc -A|grep -v Bound
oc get mcp
oc get mc -ojson|jq -r '.items|sort_by(.metadata.creationTimestamp,.metadata.name)|.[]|"\(.metadata.creationTimestamp) - \(.metadata.name)"'|tail
oc get mcp -ojson|jq -r '.items[]|"\(.metadata.name)|\(.spec.configuration.name)|\(.status.configuration.name)|\(.spec.paused)"'|column -s'|' -t
for i in $(oc get no -oname);do echo "==== $i ====";oc describe $i 2>/dev/null|grep -A8 Allocated;echo;done
for i in $(oc get no -oname|grep -vE "infra|router");do echo "==== $i ====";oc debug $i 2>/dev/null -- df -h .;echo;done
oc get po -A -owide|grep -Ev 'Completed|Succeeded|([1-9])/\1'
oc get pdb -A
oc get csr|grep Pending
oc get netpol -A
oc exec -n openshift-etcd service/etcd -c etcdctl -- etcdctl member list -wtable
oc exec -n openshift-etcd service/etcd -c etcdctl -- etcdctl endpoint status -wtable
oc exec -n openshift-etcd service/etcd -c etcdctl -- etcdctl endpoint health -wtable
oc get ev -A --field-selector type!=Normal
oc rsh -n openshift-monitoring alertmanager-main-0 amtool alert query --alertmanager.url http://localhost:9093
 
# CHECK FOR CUSTOM INSTALLED COMPONENTS
oc get po -n kube-system
 
# CHECK FOR CURRENT NETWORK PLUGIN
oc get ns|grep -E "sdn|ovn"
 
# CHECK FOR CONNECTIVITY TO DNS PODS
for ip in $(oc get ep -n openshift-dns -oyaml|awk /ip:/'{print $3}');do echo;echo Connecting to default DNS server pod with IP address $ip ...;for po in $(oc get po -owide -n openshift-dns --no-headers -oname|grep node-resolver|cut -d/ -f2);do echo -n "FROM node $(oc get po $po -n openshift-dns -owide --no-headers|awk '{print $7}') -> ";oc exec -n openshift-dns $po -- dig +notcp @$ip -p5353 dns-default.openshift-dns.svc.cluster.local 2>&1|grep Query;done;done
