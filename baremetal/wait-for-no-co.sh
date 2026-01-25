source ~/credentials.txt;

sleep 10;

while true;do
  oc get no|grep NotReady.*control-plane&&continue;
  oc get no|grep 0.*Ready.*control-plane&&oc get no|grep 1.*Ready.*control-plane&&oc get no|grep 2.*Ready.*control-plane&&break;
  oc get no;
  sleep 10;
done;

while true;do
  oc get co --no-headers|awk '{print $3}'|grep True  -q&&oc get co|awk '{print $3}'|grep -vE "AVAILABLE|True"||break;
  oc get co;
  sleep 10;
done;

while true;do
  oc get co --no-headers|awk '{print $4}'|grep False -q&&oc get co|awk '{print $4}'|grep -vE "PROGRESSING|False"||break;
  oc get co;
  sleep 10;
done;

while true;do
  oc get co --no-headers|awk '{print $5}'|grep False -q&&oc get co|awk '{print $5}'|grep -vE "DEGRADED|False"||break;
  oc get co;
  sleep 10;
done
