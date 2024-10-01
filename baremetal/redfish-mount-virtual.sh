source ~/credentials.txt;

type=master;
x=0;

host=${type}-${x};
PASS=$bmc_password;
USER=$bmc_username;

Server=$host.bmc;
Target=Managers;
TargetID=1/VirtualMedia/EXT1;

curl -d '{"Image": "https://example.com/test.iso", "TransferProtocolType": "HTTPS", "UserName": "", "Password":"", "Inserted": true}' -H "If-Match: *" -H "Content-Type: application/json" -k -L -s -u $USER:$PASS -X PATCH https://$Server/redfish/v1/$Target/$TargetID;
