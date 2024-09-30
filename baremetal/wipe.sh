deviceName=/dev/sda

command="sudo sgdisk --clear --mbrtogpt --zap-all ${deviceName}"

rm ~/.ssh/known_hosts

for x in {0..2};do echo;echo worker-$x:;ssh -o StrictHostKeyChecking=no core@worker-$x ${command};done
for x in {0..2};do echo;echo master-$x:;ssh -o StrictHostKeyChecking=no core@master-$x ${command};done
