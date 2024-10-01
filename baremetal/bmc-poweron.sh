source ~/credentials.txt;

command='chassis power on';

for type in master worker;do 
  for x in 0 1 2;do 
    host=${type}-${x}.bmc;
    echo;
    echo $host:;
    ipmitool -H $host -I lanplus -P $bmc_password -U $bmc_username $command;
  done;
done;
