source ~/credentials.txt;

type=master;
x=0;

host=${type}-${x};
PASS=$bmc_password;
USER=$bmc_username;

Server=$host.bmc;
Target=Managers;
TargetID=1;

curl -H "Content-Type: application/json" -k -L -s -u $USER:$PASS -X GET https://$Server/redfish/v1/$Target/$TargetID/|jq .|tee redfish-status-$Target-$host.json;
