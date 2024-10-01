source ./bmc-secureboot-enable.sh;

sleep 10;
while true;do
  for type in master worker;do
    for x in {0..2};do
      host=${type}-${x}.bmc;
      source ./bmc-secureboot-status.sh|grep -E ".SecureBootCurrentBoot.:.Enabled.|.SecureBootEnable.:true" -B1|grep $host||continue;
    done;
  break;
done;

sleep 10;
source ./rolling-reboot.sh;
