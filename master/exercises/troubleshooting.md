```
alias oc='oc 2>/dev/null'

oc get no|grep master

oc get no|grep worker

oc get co

oc get mcp master

oc get mcp worker

oc projects|grep machine-config

oc -n openshift-machine-config-operator get po

oc -n openshift-machine-config-operator get po -owide

oc get no ip-10-0-129-153.ap-south-1.compute.internal

oc -n openshift-machine-config-operator get po -owide|grep ip-10-0-129-153.ap-south-1.compute.internal

oc -n openshift-machine-config-operator get po machine-config-daemon-8bhh7

oc -n openshift-machine-config-operator logs machine-config-daemon-8bhh7

oc -n openshift-machine-config-operator logs machine-config-operator-79b69d9fcc-w92xb

oc projects|grep machine

oc -n openshift-machine-api get machine -oname|grep worker

oc -n openshift-machine-api get machineset

for machine in $(oc -n openshift-machine-api get machine -oname|grep worker);do oc -n openshift-machine-api delete $machine;done
```
