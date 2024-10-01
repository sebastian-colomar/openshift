source ~/credentials.txt;

command='sol activate';

type=master;
x=0;

host=${type}-${x}.bmc;

echo;
echo $host:;
ipmitool -H $host -I lanplus -P $bmc_password -U $bmc_username $command;
