source ./bmc-secureboot-enable.sh

sleep 10
while true;do
type=master;
x=0;
host=${type}-${x}.bmc;
source ./bmc-secureboot-status.sh|grep -E ".SecureBootCurrentBoot.:.Enabled.|.SecureBootEnable.:true" -B1|grep $host||continue
x=1
host=${type}-${x}.bmc;
source ./bmc-secureboot-status.sh|grep -E ".SecureBootCurrentBoot.:.Enabled.|.SecureBootEnable.:true" -B1|grep $host||continue
x=2
host=${type}-${x}.bmc;
source ./bmc-secureboot-status.sh|grep -E ".SecureBootCurrentBoot.:.Enabled.|.SecureBootEnable.:true" -B1|grep $host||continue

type=worker;
x=0;
host=${type}-${x}.bmc;
source ./bmc-secureboot-status.sh|grep -E ".SecureBootCurrentBoot.:.Enabled.|.SecureBootEnable.:true" -B1|grep $host||continue
x=1
host=${type}-${x}.bmc;
source ./bmc-secureboot-status.sh|grep -E ".SecureBootCurrentBoot.:.Enabled.|.SecureBootEnable.:true" -B1|grep $host||continue
x=2
host=${type}-${x}.bmc;
source ./bmc-secureboot-status.sh|grep -E ".SecureBootCurrentBoot.:.Enabled.|.SecureBootEnable.:true" -B1|grep $host||continue

break
done

sleep 10
source ./rolling-reboot.sh
