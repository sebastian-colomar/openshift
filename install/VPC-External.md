Instructions to install OCP in a previously created VPC:
* [VPC Example](../etc/aws/network.yaml)
  * https://github.com/secobau/proxy2aws/blob/master/proxy2aws.png

First follow these instructions:
* [Initial setup](initial.md)

In case you want to install your cluster in an already existing VPC then you will need to add the subnet IDs to the platform.aws.subnets field in the install-config.yaml previously generated:
```bash
platform:
  aws:
    subnets: 
    - subnet-public1111
    - subnet-public2222
    - subnet-public3333
    - subnet-private111
    - subnet-private222
    - subnet-private333
    
    
```    
In case of using an already existing VPC you will also need to add the CIDR block for the machine network which must include the corresponding CIDR blocks for the private and public subnets:
```bash
networking:
  machineNetwork:
  - cidr: 10.0.1.0/24
  - cidr: 10.0.2.0/24
  - cidr: 10.0.3.0/24
  - cidr: 10.0.4.0/24
  - cidr: 10.0.5.0/24
  - cidr: 10.0.6.0/24


```
Now you can proceed with the following steps:
* [Create cluster](create.md)
* [Customize certificates](certs.md)
* [Security Context Constraints](scc.md)
