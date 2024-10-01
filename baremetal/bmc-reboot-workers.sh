source ~/credentials.txt;

command='chassis power cycle';

for type in worker;do 
  for x in 0 1 2;do 
    host=${type}-${x}.bmc;
    echo;
    echo $host:;
    ipmitool -H $host -I lanplus -P $bmc_password -U $bmc_username $command;
  done;
done;
