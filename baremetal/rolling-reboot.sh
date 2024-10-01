source ~/credentials.txt;

rm ~/.ssh/known_hosts;

command='sudo systemctl reboot';

type=worker;

for x in {0..2};do
  oc debug no/${type}-$x -- chroot /host systemctl reboot;
  #ssh -o StrictHostKeyChecking=no core@${type}-$x ${command};
done;
#source ./bmc-reboot-${type}s.sh;

type=master;

for x in {0..2};do
  source ./wait-for-no-co.sh;
  oc debug no/${type}-$x -- chroot /host systemctl reboot;
  #ssh -o StrictHostKeyChecking=no core@${type}-$x ${command};
  while true;do
    oc get no|grep $x.*NotReady.*control-plane&&break;
    oc get no;
    sleep 10;
  done;
done;
#source ./bmc-reboot-${type}s.sh;

source ./wait-for-no-co.sh;
