source ~/credentials.txt;

path=1/SecureBoot;

for type in master worker;do 
  for x in 0 1 2;do 
    host=${type}-${x}.bmc;
    echo;
    echo $host:;
    curl -d '{"SecureBootEnable": false}' -H "Authorization: Basic $bmc_token" -H "Content-type: application/json" -k -s -X GET https://$host/redfish/v1/Systems/$path;
  done;
done;
