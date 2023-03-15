#!/bin/sh

while true
do
sleep 10
oc get co | awk '{ print $5 }' | grep -v -E "DEGRADED|False" || break
done

sed -i s/infra/storage/ machineset.yaml 
sed -i '/metadata.*labels.*storage/s/""/"" , node-role.kubernetes.io\/infra: "" , cluster.ocs.openshift.io\/openshift-storage: ""/' machineset.yaml    
sed -i /taints/s/node-role.kubernetes/node.ocs.openshift/ machineset.yaml 
sed -i '/taints/s/key:/value: "true" , key:/' machineset.yaml              
oc create -f machineset.yaml 

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

cat <<EOF | oc apply -f -
apiVersion: v1
kind: Namespace
metadata:
  labels:
    openshift.io/cluster-monitoring: "true"
  name: openshift-storage
spec: {}
EOF

cat <<EOF | oc apply -f -
apiVersion: operators.coreos.com/v1
kind: OperatorGroup
metadata:
  name: openshift-storage-operatorgroup
  namespace: openshift-storage
spec:
  targetNamespaces:
  - openshift-storage
EOF

cat <<EOF | oc apply -f -
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: ocs-operator
  namespace: openshift-storage
spec:
  channel: "stable-4.8" # <-- Channel should be modified depending on the OCS version to be installed. Please ensure to maintain compatibility with OCP version
  installPlanApproval: Automatic
  name: ocs-operator
  source: redhat-operators  # <-- Modify the name of the redhat-operators catalogsource if not default
  sourceNamespace: openshift-marketplace
EOF


while true
do
sleep 10
oc get crd -A | grep storageclusters.ocs.openshift.io && break
done

cat 0<<EOF | oc apply -f -
apiVersion: ocs.openshift.io/v1
kind: StorageCluster
metadata:
  annotations:
    uninstall.ocs.openshift.io/cleanup-policy: delete
    uninstall.ocs.openshift.io/mode: graceful
  name: ocs-storagecluster
  namespace: openshift-storage
spec:
  arbiter: {}
  encryption:
    kms: {}
  externalStorage: {}
  managedResources:
    cephBlockPools: {}
    cephConfig: {}
    cephDashboard: {}
    cephFilesystems: {}
    cephObjectStoreUsers: {}
    cephObjectStores: {}
  nodeTopologies: {}
  storageDeviceSets:
    - config: {}
      resources: {}
      placement: {}
      name: ocs-deviceset-gp2
      dataPVCTemplate:
        metadata: {}
        spec:
          accessModes:
            - ReadWriteOnce
          resources:
            requests:
              storage: 512Gi
          storageClassName: gp2
          volumeMode: Block
        status: {}
      count: 1
      replica: 3
      portable: true
      preparePlacement: {}
EOF

while true
do
sleep 10
oc get po -n openshift-storage | grep -v -E "STATUS|Completed|Running" || break
done
