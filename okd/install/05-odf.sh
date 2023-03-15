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
  name: odf-operator
  namespace: openshift-storage
spec:
  channel: "stable-4.9" # <-- Channel should be modified depending on the OCS version to be installed. Please ensure to maintain compatibility with OCP version
  installPlanApproval: Automatic
  name: odf-operator
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
    storagesystem.odf.openshift.io/watched-by: ocs-storagecluster-storagesystem
    uninstall.ocs.openshift.io/cleanup-policy: delete
    uninstall.ocs.openshift.io/mode: graceful
  finalizers:
  - storagecluster.ocs.openshift.io
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
    count: 1
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
    name: ocs-deviceset-gp2
    placement: {}
    portable: true
    preparePlacement: {}
    replica: 3
    resources: {}
  version: 4.9.0
EOF

while true
do
sleep 10
oc get crd -A | grep storagesystems.odf.openshift.io && break
done

cat 0<<EOF | oc apply -f -
apiVersion: odf.openshift.io/v1alpha1
kind: StorageSystem
metadata:
  finalizers:
  - storagesystem.odf.openshift.io
  name: ocs-storagecluster-storagesystem
  namespace: openshift-storage
spec:
  kind: storagecluster.ocs.openshift.io/v1
  name: ocs-storagecluster
  namespace: openshift-storage
EOF

oc patch console.operator cluster -n openshift-storage --type json -p '[{"op": "add", "path": "/spec/plugins", "value": ["odf-console"]}]'

while true
do
sleep 10
oc get po -n openshift-storage | grep -v -E "STATUS|Completed|Running" || break
done
