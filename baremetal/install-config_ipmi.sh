source ./conf.d/install-config_ipmi.conf

tee ~/install-config.yaml 0<<EOF
apiVersion: v1
baseDomain: '${baseDomain}'
compute:
- name: worker
  architecture: '${compute_architecture}'
  platform:
    baremetal: {}
  replicas: ${compute_replicas}
controlPlane:
  name: master
  architecture: '${controlPlane_architecture}'
  platform:
    baremetal: {}
  replicas: ${controlPlane_replicas}
metadata:
  name: '${name}'
networking:
  machineNetwork:
  - cidr: '${machineNetwork}'
  networkType: '${networkType}'
platform:
  baremetal:
    apiVIPs:
      - '${apiVIP}'
    ingressVIPs:
      - '${ingressVIP}'
    bootstrapExternalStaticDNS: '${bootstrapExternalStaticDNS}'
    bootstrapExternalStaticGateway: '${bootstrapExternalStaticGateway}'
    bootstrapExternalStaticIP: '${bootstrapExternalStaticIP}'
    bootstrapOSImage: '${bootstrapOSImage}'
    externalBridge: '${externalBridge}'
    provisioningBridge: '${provisioningBridge}'
    provisioningNetwork: '${provisioningNetwork}'
    provisioningNetworkCIDR: '${provisioningNetworkCIDR}'
    hosts:
      - name: master-0
        bmc:
          address: '${protocol}://${master_0_address}/${path}'
          disableCertificateVerification: ${disableCertificateVerification}
          password: '${bmc_password}'
          username: '${bmc_username}'
        bootMACAddress: '${master_0_bootMACAddress}'
        bootMode: '${bootMode}'
        role: master
        rootDeviceHints:
         deviceName: '${deviceName}'
      - name: master-1
        bmc:
          address: '${protocol}://${master_1_address}/${path}'
          disableCertificateVerification: ${disableCertificateVerification}
          password: '${bmc_password}'
          username: '${bmc_username}'
        bootMACAddress: '${master_1_bootMACAddress}'
        bootMode: '${bootMode}'
        role: master
        rootDeviceHints:
         deviceName: '${deviceName}'
      - name: master-2
        bmc:
          address: '${protocol}://${master_2_address}/${path}'
          disableCertificateVerification: ${disableCertificateVerification}
          password: '${bmc_password}'
          username: '${bmc_username}'
        bootMACAddress: '${master_2_bootMACAddress}'
        bootMode: '${bootMode}'
        role: master
        rootDeviceHints:
         deviceName: '${deviceName}'
      - name: worker-0
        bmc:
          address: '${protocol}://${worker_0_address}/${path}'
          disableCertificateVerification: ${disableCertificateVerification}
          password: '${bmc_password}'
          username: '${bmc_username}'
        bootMACAddress: '${worker_0_bootMACAddress}'
        bootMode: '${bootMode}'
        role: worker
        rootDeviceHints:
         deviceName: '${deviceName}'
      - name: worker-1
        bmc:
          address: '${protocol}://${worker_1_address}/${path}'
          disableCertificateVerification: ${disableCertificateVerification}
          password: '${bmc_password}'
          username: '${bmc_username}'
        bootMACAddress: '${worker_1_bootMACAddress}'
        bootMode: '${bootMode}'
        role: worker
        rootDeviceHints:
         deviceName: '${deviceName}'
      - name: worker-2
        bmc:
          address: '${protocol}://${worker_2_address}/${path}'
          disableCertificateVerification: ${disableCertificateVerification}
          password: '${bmc_password}'
          username: '${bmc_username}'
        bootMACAddress: '${worker_2_bootMACAddress}'
        bootMode: '${bootMode}'
        role: worker
        rootDeviceHints:
         deviceName: '${deviceName}'
pullSecret: '${pullSecret}'
sshKey: '${sshKey}'
EOF

rm -rf ~/clusterconfigs
mkdir ~/clusterconfigs
cp ~/install-config.yaml ~/clusterconfigs
