Instructions to install OCP in a previously created VPC:
* [VPC Example](../etc/aws/network.yaml)
  * https://github.com/secobau/proxy2aws/blob/master/proxy2aws.png

First follow these instructions:
* [Initial setup](initial.md)

Be sure to enable the following features in the VPC configuration in case your cluster is private:
```bash
DNS resolution Enabled
DNS hostnames  Enabled


```
In case you want to install your cluster in an already existing VPC then you will need to add the subnet IDs to the platform.aws.subnets field:
```bash
platform:
  aws:
    subnets: 
    - subnet-private111
    - subnet-private222
    - subnet-private333
    
    
```    
In case of using an already existing VPC you will also need to add the CIDR blocks for the machine network which must coincide with the corresponding CIDR blocks for the private subnets:
```bash
networking:
  machineNetwork:
  - cidr: 10.0.1.0/24
  - cidr: 10.0.3.0/24
  - cidr: 10.0.5.0/24


```
Now you can proceed with the following steps:
* [Create cluster](create.md)
* [Customize certificates](certs.md)
* [Security Context Constraints](scc.md)
