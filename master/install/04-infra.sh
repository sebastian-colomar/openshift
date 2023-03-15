#!/bin/sh

while true
do
sleep 10
oc get co | awk '{ print $5 }' | grep -v -E "DEGRADED|False" || break
done

oc get machineset -A -o yaml | tee machineset.yaml

sed -i /creationTimestamp:/d machineset.yaml 
sed -i /generation:/d machineset.yaml 
sed -i /resourceVersion:/d machineset.yaml 
sed -i /uid:/d machineset.yaml 
sed -i '/status:/,+5d' machineset.yaml 
sed -i '/name:.*\-worker/s/worker/infra/' machineset.yaml 
sed -i '/cluster-api-machineset:.*\-worker/s/worker/infra/' machineset.yaml   
sed -i /cluster-api-machine-.*worker/s/worker/infra/ machineset.yaml          
sed -i '/metadata: {}/s/$/\n        taints: [ { key: node-role.kubernetes.io\/infra , effect: NoSchedule } ]/' machineset.yaml
sed -i 's/metadata: {}/metadata: { labels: { node-role.kubernetes.io\/infra: "" } }/' machineset.yaml   

oc apply -f machineset.yaml 

while true
do
sleep 10
oc get machine -A | grep -v -E "PHASE|Running" || break
done

while true
do
sleep 10
oc get no | grep -v -E "STATUS|Ready" || break
done

oc get ingresscontroller default -n openshift-ingress-operator -o yaml | tee ingresscontroller.yaml
sed -i '/^spec:/s/$/\n  nodePlacement:\n    nodeSelector:\n      matchLabels:\n        node-role.kubernetes.io\/infra: ""\n    tolerations:\n    - effect: NoSchedule\n      key: node-role.kubernetes.io\/infra\n      operator: Exists/' ingresscontroller.yaml
oc apply -f ingresscontroller.yaml 

cat 0<<EOF | oc apply -f -
apiVersion: v1
data:
  config.yaml: "alertmanagerMain:\n  nodeSelector:\n
    \   node-role.kubernetes.io/infra: \"\"\n  tolerations:\n    - effect: NoSchedule
    \n      key: node-role.kubernetes.io/infra \n      operator: Exists        \nprometheusK8s:\n  nodeSelector:\n    node-role.kubernetes.io/infra:
    \"\"\n  tolerations:\n    - effect: NoSchedule \n      key: node-role.kubernetes.io/infra
    \n      operator: Exists\nprometheusOperator:\n  nodeSelector:\n    node-role.kubernetes.io/infra:
    \"\"\n  tolerations:\n    - effect: NoSchedule \n      key: node-role.kubernetes.io/infra
    \n      operator: Exists\ngrafana:\n  nodeSelector:\n    node-role.kubernetes.io/infra:
    \"\"\n  tolerations:\n    - effect: NoSchedule \n      key: node-role.kubernetes.io/infra
    \n      operator: Exists\nk8sPrometheusAdapter:\n  nodeSelector:\n    node-role.kubernetes.io/infra:
    \"\"\n  tolerations:\n    - effect: NoSchedule \n      key: node-role.kubernetes.io/infra
    \n      operator: Exists\nkubeStateMetrics:\n  nodeSelector:\n    node-role.kubernetes.io/infra:
    \"\"\n  tolerations:\n    - effect: NoSchedule \n      key: node-role.kubernetes.io/infra
    \n      operator: Exists\ntelemeterClient:\n  nodeSelector:\n    node-role.kubernetes.io/infra:
    \"\"\n  tolerations:\n    - effect: NoSchedule \n      key: node-role.kubernetes.io/infra
    \n      operator: Exists\nopenshiftStateMetrics:\n  nodeSelector:\n    node-role.kubernetes.io/infra:
    \"\"\n  tolerations:\n    - effect: NoSchedule \n      key: node-role.kubernetes.io/infra
    \n      operator: Exists\nthanosQuerier:\n  nodeSelector:\n    node-role.kubernetes.io/infra:
    \"\"\n  tolerations:\n    - effect: NoSchedule \n      key: node-role.kubernetes.io/infra
    \n      operator: Exists\n"
kind: ConfigMap
metadata:
  name: cluster-monitoring-config
  namespace: openshift-monitoring
EOF
