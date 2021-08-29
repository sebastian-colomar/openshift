First follow these instructions:
* [Initial setup](initial.md)

After the previous step is finished then you may proceed.

Set the number of compute replicas to zero:
```bash
sed --in-place /compute/,/controlPlane/s/\ 3/\ 0/ $dir/install-config.yaml
git commit -am 'Set the number of compute replicas to zero'


```
It is a good idea to make a copy of your configuration file if you are not using git:
```bash
cp $dir/install-config.yaml $dir/install-config.yaml.$( date +%F_%H%M )


```
Now you generate the Kubernetes manifests for the cluster:
```BASH
openshift-install-$version create manifests --dir $dir --log-level debug
git add .
git commit -am 'Generate the Kubernetes manifests for the cluster'


```
Remove the Kubernetes manifest files that define the control plane machines:
```BASH
rm --force $dir/openshift/99_openshift-cluster-api_master-machines-*.yaml
git commit -am 'Remove the Kubernetes manifest files that define the control plane machines'


```
Remove the Kubernetes manifest files that define the worker machines:
```BASH
rm --force $dir/openshift/99_openshift-cluster-api_worker-machineset-*.yaml
git commit -am 'Remove the Kubernetes manifest files that define the worker machines'


```
Prevent Pods from being scheduled on the control plane machines:
```bash
sed --in-place /mastersSchedulable/s/true/false/ $dir/manifests/cluster-scheduler-02-config.yml
git commit -am 'Prevent Pods from being scheduled on the control plane machines'


```
If you do not want the Ingress Operator to create DNS records on your behalf, remove the privateZone and publicZone sections from the DNS configuration file:
```bash
sed --in-place /privateZone:/,/id:/d $dir/manifests/cluster-dns-02-config.yml
git commit -am 'Remove the privateZone and publicZone sections from the DNS configuration file'


```
Obtain the Ignition config files:
```BASH
openshift-install-$version create ignition-configs --dir $dir --log-level debug
git add .
git commit -m 'Obtain the Ignition config files'


```
Creating a VPC in AWS:
* [ocp-vpc.json](ocp-vpc.json)
* [ocp-vpc.yaml](ocp-vpc.yaml)
```BASH
export VpcCidr=10.0.0.0/16
export AvailabilityZoneCount=3
export SubnetBits=13

export file=ocp-vpc.json
wget https://raw.githubusercontent.com/secobau/openshift/master/install/$file --directory-prefix $dir
sed --in-place s/VpcCidr_Value/"$( echo $VpcCidr | sed 's/\//\\\//g' )"/ $dir/$file
sed --in-place s/AvailabilityZoneCount_Value/"$AvailabilityZoneCount"/ $dir/$file
sed --in-place s/SubnetBits_Value/"$SubnetBits"/ $dir/$file

export file=${file%.json}.yaml
wget https://raw.githubusercontent.com/secobau/openshift/master/install/$file --directory-prefix $dir
aws cloudformation create-stack --stack-name ${file%.yaml} --template-body file://$dir/$file --parameters file://$dir/${file%.yaml}.json
git add .
git commit -am 'Creating a VPC in AWS'


```
In case you have configured your cluster not to be externally published then you need to continue the installation from inside the internal VPC.
For that purpose you will create a new Cloud9 environment in a public subnet of the internal VPC if available.
Otherwise you will need to create a bastion machine inside the private subnet and access the bastion through SSH.
Anyway you will need to download the project files of your Cloud9 environment including the SSH keys and the AWS credentials:
```bash
cp -r $HOME/.ssh $dir
cp -r $HOME/.aws $dir
export | grep -E " version=| ClusterName=| DomainName=| dir=| Publish=| VpcCidr=| AvailabilityZoneCount=| SubnetBits=| file=" 1> $HOME/environment/variables.sh


```
Once you have created the new Cloud9 environment you need to disable the AWS managed temporary credentials in AWS Cloud9 settings and upload the previously downloaded project.

You need to export the values for these variables from the old Cloud9 environment to the new Cloud9 environment:
```bash
echo export dir=$dir
echo export version=$version


```
You will again need to download and install the client installer binaries:
```bash
export dir=xxx
export version=xxx

mv openshift.tar.gz  ..
cd ..
gunzip openshift.tar.gz
tar xf openshift.tar
rm openshift.tar
source $HOME/environment/variables.sh
rm -rf $HOME/.ssh && mv $dir/.ssh $HOME
rm -rf $HOME/.aws && mv $dir/.aws $HOME

for mode in client install
do
  wget https://mirror.openshift.com/pub/openshift-v4/clients/ocp/$version/openshift-$mode-linux-$version.tar.gz
  gunzip openshift-$mode-linux-$version.tar.gz
  tar xf openshift-$mode-linux-$version.tar
  rm openshift-$mode-linux-$version.tar
done
mkdir --parents $HOME/bin
for binary in kubectl oc
do
  mv $binary $HOME/bin
done
mv openshift-install $HOME/bin/openshift-install-$version
file=README.md 
test -f $file && rm -f $file
file=$HOME/bin/openshift-install
test -f $file && rm -f $file
ln -s $HOME/bin/openshift-install-$version $HOME/bin/openshift-install

cd $dir
git config --global user.name "Your Name"
git config --global user.email you@example.com


```
Once the stack creation is completed you can get the following values:
```BASH
export PrivateSubnets="$( aws cloudformation describe-stacks --stack-name ${file%.yaml} --query Stacks[].Outputs[0].OutputValue --output text )"
export PublicSubnets="$( aws cloudformation describe-stacks --stack-name ${file%.yaml} --query Stacks[].Outputs[1].OutputValue --output text )"
export VpcId="$( aws cloudformation describe-stacks --stack-name ${file%.yaml} --query Stacks[].Outputs[2].OutputValue --output text )"

sudo yum install --assumeyes jq

export InfrastructureName="$( jq --raw-output .infraID $dir/metadata.json )"
export HostedZoneId="$( aws route53 list-hosted-zones-by-name | jq --arg name "$DomainName." --raw-output '.HostedZones | .[] | select(.Name=="\($name)") | .Id' | cut --delimiter / --field 3 )"


```
Creating networking and load balancing components in AWS:
* [ocp-route53-External.json](ocp-route53-External.json)
* [ocp-route53-External.yaml](ocp-route53-External.yaml)
* [ocp-route53-Internal.json](ocp-route53-Internal.json)
* [ocp-route53-Internal.yaml](ocp-route53-Internal.yaml)
```BASH
file=ocp-route53-$Publish.json
wget https://raw.githubusercontent.com/secobau/openshift/master/install/$file --directory-prefix $dir
sed --in-place s/ClusterName_Value/"$ClusterName"/ $dir/$file
sed --in-place s/HostedZoneId_Value/"$HostedZoneId"/ $dir/$file
sed --in-place s/HostedZoneName_Value/"$DomainName"/ $dir/$file
sed --in-place s/InfrastructureName_Value/"$InfrastructureName"/ $dir/$file
sed --in-place s/Publish_Value/"$Publish"/ $dir/$file
sed --in-place s/PrivateSubnets_Value/"$PrivateSubnets"/ $dir/$file
sed --in-place s/VpcId_Value/"$VpcId"/ $dir/$file

test $Publish = External && sed --in-place s/PublicSubnets_Value/"$PublicSubnets"/ $dir/$file

file=${file%.json}.yaml
wget https://raw.githubusercontent.com/secobau/openshift/master/install/$file --directory-prefix $dir
aws cloudformation create-stack --stack-name ${file%.yaml} --template-body file://$dir/$file --parameters file://$dir/${file%.yaml}.json --capabilities CAPABILITY_NAMED_IAM

cd $dir && git add . && git commit -am 'Creating networking and load balancing components in AWS'


```
Once the stack creation is completed you can get the following values:
```BASH
if test $Publish = External
then
export ExternalApiTargetGroupArn=$( aws cloudformation describe-stacks --stack-name ${file%.yaml} --query Stacks[].Outputs[0].OutputValue --output text )
export InternalApiTargetGroupArn=$( aws cloudformation describe-stacks --stack-name ${file%.yaml} --query Stacks[].Outputs[1].OutputValue --output text )
export PrivateHostedZoneId=$( aws cloudformation describe-stacks --stack-name ${file%.yaml} --query Stacks[].Outputs[3].OutputValue --output text )
export RegisterNlbIpTargetsLambdaArn=$( aws cloudformation describe-stacks --stack-name ${file%.yaml} --query Stacks[].Outputs[5].OutputValue --output text )
export InternalServiceTargetGroupArn=$( aws cloudformation describe-stacks --stack-name ${file%.yaml} --query Stacks[].Outputs[6].OutputValue --output text )
else
export InternalApiTargetGroupArn=$( aws cloudformation describe-stacks --stack-name ${file%.yaml} --query Stacks[].Outputs[0].OutputValue --output text )
export PrivateHostedZoneId=$( aws cloudformation describe-stacks --stack-name ${file%.yaml} --query Stacks[].Outputs[2].OutputValue --output text )
export RegisterNlbIpTargetsLambdaArn=$( aws cloudformation describe-stacks --stack-name ${file%.yaml} --query Stacks[].Outputs[4].OutputValue --output text )
export InternalServiceTargetGroupArn=$( aws cloudformation describe-stacks --stack-name ${file%.yaml} --query Stacks[].Outputs[5].OutputValue --output text )
fi


```
Creating security group and roles in AWS:
* [ocp-roles.json](ocp-roles.json)
* [ocp-roles.yaml](ocp-roles.yaml)
```BASH
file=ocp-roles.json
wget https://raw.githubusercontent.com/secobau/openshift/master/install/$file --directory-prefix $dir
sed --in-place s/InfrastructureName_Value/"$InfrastructureName"/ $dir/$file
sed --in-place s/PrivateSubnets_Value/"$PrivateSubnets"/ $dir/$file
sed --in-place s/VpcCidr_Value/"$( echo $VpcCidr | sed 's/\//\\\//g' )"/ $dir/$file
sed --in-place s/VpcId_Value/"$VpcId"/ $dir/$file

file=${file%.json}.yaml
wget https://raw.githubusercontent.com/secobau/openshift/master/install/$file --directory-prefix $dir
aws cloudformation create-stack --stack-name ${file%.yaml} --template-body file://$dir/$file --parameters file://$dir/${file%.yaml}.json --capabilities CAPABILITY_NAMED_IAM

cd $dir && git add . && git commit -am 'Creating security group and roles in AWS'


```
Once the stack creation is completed you can get the following values:
```BASH
export MasterSecurityGroupId=$( aws cloudformation describe-stacks --stack-name ${file%.yaml} --query Stacks[].Outputs[0].OutputValue --output text )
export MasterInstanceProfileName=$( aws cloudformation describe-stacks --stack-name ${file%.yaml} --query Stacks[].Outputs[1].OutputValue --output text )
export WorkerSecurityGroupId=$( aws cloudformation describe-stacks --stack-name ${file%.yaml} --query Stacks[].Outputs[2].OutputValue --output text )
export WorkerInstanceProfileName=$( aws cloudformation describe-stacks --stack-name ${file%.yaml} --query Stacks[].Outputs[3].OutputValue --output text )


```
Creating the bootstrap node in AWS:
* [ocp-bootstrap-External.json](ocp-bootstrap-External.json)
* [ocp-bootstrap-External.yaml](ocp-bootstrap-External.yaml)
* [ocp-bootstrap-Internal.json](ocp-bootstrap-Internal.json)
* [ocp-bootstrap-Internal.yaml](ocp-bootstrap-Internal.yaml)
```BASH
export RhcosAmi=ami-0754b15d212830477
export AllowedBootstrapSshCidr=0.0.0.0/0
export BootstrapIgnitionLocation=s3://$InfrastructureName/bootstrap.ign
export AutoRegisterELB=yes
export PublicSubnet=$( echo $PublicSubnets | cut --delimiter , --field 1 )

aws s3 mb s3://$InfrastructureName
aws s3 cp $dir/bootstrap.ign $BootstrapIgnitionLocation
aws s3 ls s3://$InfrastructureName/

file=ocp-bootstrap-$Publish.json
wget https://raw.githubusercontent.com/secobau/openshift/master/install/$file --directory-prefix $dir
sed --in-place s/InfrastructureName_Value/"$InfrastructureName"/ $dir/$file
sed --in-place s/RhcosAmi_Value/"$RhcosAmi"/ $dir/$file
sed --in-place s/AllowedBootstrapSshCidr_Value/"$( echo $AllowedBootstrapSshCidr | sed 's/\//\\\//g' )"/ $dir/$file
sed --in-place s/MasterSecurityGroupId_Value/"$MasterSecurityGroupId"/ $dir/$file
sed --in-place s/VpcId_Value/"$VpcId"/ $dir/$file
sed --in-place s/BootstrapIgnitionLocation_Value/"$( echo $BootstrapIgnitionLocation | sed 's/\//\\\//g' )"/ $dir/$file
sed --in-place s/AutoRegisterELB_Value/"$AutoRegisterELB"/ $dir/$file
sed --in-place s/RegisterNlbIpTargetsLambdaArn_Value/"$( echo $RegisterNlbIpTargetsLambdaArn | sed 's/\//\\\//g' )"/ $dir/$file
sed --in-place s/InternalApiTargetGroupArn_Value/"$( echo $InternalApiTargetGroupArn | sed 's/\//\\\//g' )"/ $dir/$file
sed --in-place s/InternalServiceTargetGroupArn_Value/"$( echo $InternalServiceTargetGroupArn | sed 's/\//\\\//g' )"/ $dir/$file
sed --in-place s/PublicSubnet_Value/"$PublicSubnet"/ $dir/$file

test $Publish = External && sed --in-place s/ExternalApiTargetGroupArn_Value/"$( echo $ExternalApiTargetGroupArn | sed 's/\//\\\//g' )"/ $dir/$file

file=${file%.json}.yaml
wget https://raw.githubusercontent.com/secobau/openshift/master/install/$file --directory-prefix $dir
aws cloudformation create-stack --stack-name ${file%.yaml} --template-body file://$dir/$file --parameters file://$dir/${file%.yaml}.json --capabilities CAPABILITY_NAMED_IAM

cd $dir && git add . && git commit -am 'Creating the bootstrap node in AWS'


```
Creating the control plane machines in AWS:
* [ocp-master-External.json](ocp-master-External.json)
* [ocp-master-External.yaml](ocp-master-External.yaml)
* [ocp-master-Internal.json](ocp-master-Internal.json)
* [ocp-master-Internal.yaml](ocp-master-Internal.yaml)
```BASH
export AutoRegisterDNS=yes
export PrivateHostedZoneName=$ClusterName.$DomainName
export Master0Subnet=$( echo $PrivateSubnets | cut --delimiter , --field 1 )
export Master1Subnet=$( echo $PrivateSubnets | cut --delimiter , --field 2 )
export Master2Subnet=$( echo $PrivateSubnets | cut --delimiter , --field 3 )
export IgnitionLocation=https://api-int.$PrivateHostedZoneName:22623/config/master
export CertificateAuthorities=$( jq .ignition.security.tls.certificateAuthorities[0].source --raw-output $dir/master.ign )
export MasterInstanceType=t3a.xlarge

file=ocp-master-$Publish.json
wget https://raw.githubusercontent.com/secobau/openshift/master/install/$file --directory-prefix $dir
sed --in-place s/InfrastructureName_Value/"$InfrastructureName"/ $dir/$file
sed --in-place s/RhcosAmi_Value/"$RhcosAmi"/ $dir/$file
sed --in-place s/AutoRegisterDNS_Value/"$AutoRegisterDNS"/ $dir/$file
sed --in-place s/PrivateHostedZoneId_Value/"$PrivateHostedZoneId"/ $dir/$file
sed --in-place s/PrivateHostedZoneName_Value/"$PrivateHostedZoneName"/ $dir/$file
sed --in-place s/Master0Subnet_Value/"$Master0Subnet"/ $dir/$file
sed --in-place s/Master1Subnet_Value/"$Master1Subnet"/ $dir/$file
sed --in-place s/Master2Subnet_Value/"$Master2Subnet"/ $dir/$file
sed --in-place s/MasterSecurityGroupId_Value/"$MasterSecurityGroupId"/ $dir/$file
sed --in-place s/IgnitionLocation_Value/"$( echo $IgnitionLocation | sed 's/\//\\\//g' )"/ $dir/$file
sed --in-place s/CertificateAuthorities_Value/"$( echo $CertificateAuthorities | sed 's/\//\\\//g' )"/ $dir/$file
sed --in-place s/MasterInstanceProfileName_Value/"$MasterInstanceProfileName"/ $dir/$file
sed --in-place s/MasterInstanceType_Value/"$MasterInstanceType"/ $dir/$file
sed --in-place s/AutoRegisterELB_Value/"$AutoRegisterELB"/ $dir/$file
sed --in-place s/RegisterNlbIpTargetsLambdaArn_Value/"$( echo $RegisterNlbIpTargetsLambdaArn | sed 's/\//\\\//g' )"/ $dir/$file
sed --in-place s/InternalApiTargetGroupArn_Value/"$( echo $InternalApiTargetGroupArn | sed 's/\//\\\//g' )"/ $dir/$file
sed --in-place s/InternalServiceTargetGroupArn_Value/"$( echo $InternalServiceTargetGroupArn | sed 's/\//\\\//g' )"/ $dir/$file

test $Publish = External && sed --in-place s/ExternalApiTargetGroupArn_Value/"$( echo $ExternalApiTargetGroupArn | sed 's/\//\\\//g' )"/ $dir/$file

file=${file%.json}.yaml
wget https://raw.githubusercontent.com/secobau/openshift/master/install/$file --directory-prefix $dir
aws cloudformation create-stack --stack-name ${file%.yaml} --template-body file://$dir/$file --parameters file://$dir/${file%.yaml}.json

cd $dir && git add . && git commit -am 'Creating the control plane machines in AWS'


```
Once both stack creations are completed you can initialize the bootstrap node on AWS with user-provisioned infrastructure:
```BASH
openshift-install-$version wait-for bootstrap-complete --dir $dir --log-level debug
cd $dir && git commit -am 'Initialize the bootstrap node on AWS with user-provisioned infrastructure'


```
Creating the worker nodes in AWS:
* [ocp-worker.json](ocp-worker.json)
* [ocp-worker.yaml](ocp-worker.yaml)
```BASH
export IgnitionLocation=https://api-int.$PrivateHostedZoneName:22623/config/worker
export CertificateAuthorities=$( jq .ignition.security.tls.certificateAuthorities[0].source --raw-output $dir/worker.ign )
export WorkerInstanceType=t3a.large
export Worker0Subnet=$( echo $PrivateSubnets | cut --delimiter , --field 1 )
export Worker1Subnet=$( echo $PrivateSubnets | cut --delimiter , --field 2 )
export Worker2Subnet=$( echo $PrivateSubnets | cut --delimiter , --field 3 )

file=ocp-worker.json
wget https://raw.githubusercontent.com/secobau/openshift/master/install/$file --directory-prefix $dir
sed --in-place s/InfrastructureName_Value/"$InfrastructureName"/ $dir/$file
sed --in-place s/RhcosAmi_Value/"$RhcosAmi"/ $dir/$file
sed --in-place s/WorkerSecurityGroupId_Value/"$WorkerSecurityGroupId"/ $dir/$file
sed --in-place s/IgnitionLocation_Value/"$( echo $IgnitionLocation | sed 's/\//\\\//g' )"/ $dir/$file
sed --in-place s/CertificateAuthorities_Value/"$( echo $CertificateAuthorities | sed 's/\//\\\//g' )"/ $dir/$file
sed --in-place s/WorkerInstanceProfileName_Value/"$WorkerInstanceProfileName"/ $dir/$file
sed --in-place s/WorkerInstanceType_Value/"$WorkerInstanceType"/ $dir/$file
sed --in-place s/Subnet0_Value/"$Worker0Subnet"/ $dir/$file
sed --in-place s/Subnet1_Value/"$Worker1Subnet"/ $dir/$file
sed --in-place s/Subnet2_Value/"$Worker2Subnet"/ $dir/$file

file=${file%.json}.yaml
wget https://raw.githubusercontent.com/secobau/openshift/master/install/$file --directory-prefix $dir
aws cloudformation create-stack --stack-name ${file%.yaml} --template-body file://$dir/$file --parameters file://$dir/${file%.yaml}.json

cd $dir && git add . && git commit -am 'Creating the worker nodes in AWS'


```
Logging in to the cluster:
```BASH
export KUBECONFIG=$dir/auth/kubeconfig


```
Approving the CSRs for your machines:
```bash
oc get csr -o go-template='{{range .items}}{{if not .status}}{{.metadata.name}}{{"\n"}}{{end}}{{end}}' | xargs oc adm certificate approve


```
Watch the cluster components come online:
```bash
oc get clusteroperator


```
After you complete the initial Operator configuration for the cluster, remove the bootstrap resources from Amazon Web Services (AWS):
```bash
aws cloudformation delete-stack --stack-name ocp-bootstrap-$Publish


```
Creating the Ingress DNS Records:
```bash
export routes="$( oc get --all-namespaces -o jsonpath='{range .items[*]}{range .status.ingress[*]}{.host}{"\n"}{end}{end}' routes | cut --delimiter . --field 1 )"
export hostname=$( oc -n openshift-ingress get service router-default -o custom-columns=:.status.loadBalancer.ingress[].hostname --no-headers )
export CanonicalHostedZoneNameID=$( aws elb describe-load-balancers | jq -r '.LoadBalancerDescriptions[] | select(.DNSName == "'$hostname'").CanonicalHostedZoneNameID' )
export PrivateHostedZoneId="$( aws route53 list-hosted-zones-by-name | jq --arg name "$ClusterName.$DomainName." --raw-output '.HostedZones | .[] | select(.Name=="\($name)") | .Id' | cut --delimiter / --field 3 )"

test $Publish = External && export PublicHostedZoneId="$( aws route53 list-hosted-zones-by-name | jq --arg name "$DomainName." --raw-output '.HostedZones | .[] | select(.Name=="\($name)") | .Id' | cut --delimiter / --field 3 )"

for route in $routes
do
aws route53 change-resource-record-sets --hosted-zone-id "$PrivateHostedZoneId" --change-batch '{ "Changes": [ { "Action": "CREATE", "ResourceRecordSet": { "Name": "'$route'.apps.'$ClusterName.$DomainName'", "Type": "A", "AliasTarget":{ "HostedZoneId": "'$CanonicalHostedZoneNameID'", "DNSName": "'$hostname'.", "EvaluateTargetHealth": false } } } ] }'
test $Publish = External && aws route53 change-resource-record-sets --hosted-zone-id "$PublicHostedZoneId" --change-batch '{ "Changes": [ { "Action": "CREATE", "ResourceRecordSet": { "Name": "'$route'.apps.'$ClusterName.$DomainName'", "Type": "A", "AliasTarget":{ "HostedZoneId": "'$CanonicalHostedZoneNameID'", "DNSName": "'$hostname'.", "EvaluateTargetHealth": false } } } ] }'
done


```
Completing the AWS installation on user-provisioned infrastructure:
```bash
openshift-install-$version wait-for install-complete --dir $dir --log-level debug
cd $dir && git commit -am 'Completing the AWS installation on user-provisioned infrastructure'


```
Now you can optionally customize the default certificates:
* [Customize certificates](certs.md)

#### Credits

This documentation is based on this: https://docs.openshift.com/container-platform/4.5/installing/installing_aws/installing-aws-user-infra.html
