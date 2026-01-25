# Set the number of compute replicas to zero:
sed --in-place /compute/,/controlPlane/s/\ 3/\ 0/ $dir/install-config.yaml

# It is a good idea to make a copy of your configuration file:
rm -f ${dir}/install-config.yaml.bak
cp -f ${dir}/install-config.yaml ${dir}/install-config.yaml.bak

# Now you generate the Kubernetes manifests for the cluster:
openshift-install-$version create manifests --dir $dir --log-level debug

# Remove the Kubernetes manifest files that define the control plane machines:
rm --force $dir/openshift/99_openshift-cluster-api_master-machines-*.yaml

# Remove the Kubernetes manifest files that define the control plane machine set:
rm --force $dir/openshift/99_openshift-machine-api_master-control-plane-machine-set.yaml

# Remove the Kubernetes manifest files that define the worker machines:
rm --force $dir/openshift/99_openshift-cluster-api_worker-machineset-*.yaml

# Prevent Pods from being scheduled on the control plane machines:
sed --in-place /mastersSchedulable/s/true/false/ $dir/manifests/cluster-scheduler-02-config.yml

# If you do not want the Ingress Operator to create DNS records on your behalf, remove the privateZone and publicZone sections from the DNS configuration file:
sed --in-place /privateZone:/,/id:/d $dir/manifests/cluster-dns-02-config.yml

# Obtain the Ignition config files:
openshift-install-$version create ignition-configs --dir $dir --log-level debug

# Export a few environment variables:
export github_username=sebastian-colomar
export github_reponame=openshift
export github_branch=master

# Creating a VPC in AWS:
export AvailabilityZoneCount=3
export SubnetBits=$((32 - hostPrefix))
export VpcCidr=${MachineNetworkCIDR}
export file=ocp-vpc.json
cp -v ${pwd}/${file} ${dir}
sed --in-place s/VpcCidr_Value/"$( echo $VpcCidr | sed 's/\//\\\//g' )"/ $dir/$file
sed --in-place s/AvailabilityZoneCount_Value/"$AvailabilityZoneCount"/ $dir/$file
sed --in-place s/SubnetBits_Value/"$SubnetBits"/ $dir/$file
export file=${file%.json}.yaml
cp -v ${pwd}/${file} ${dir}
aws cloudformation create-stack --stack-name ${file%.yaml} --template-body file://$dir/$file --parameters file://$dir/${file%.yaml}.json

# Once the stack creation is completed you can get the following values:
aws cloudformation wait stack-create-complete --stack-name ${file%.yaml}
export PrivateSubnets="$( aws cloudformation describe-stacks --stack-name ${file%.yaml} --query Stacks[].Outputs[0].OutputValue --output text )"
export PublicSubnets="$( aws cloudformation describe-stacks --stack-name ${file%.yaml} --query Stacks[].Outputs[1].OutputValue --output text )"
export VpcId="$( aws cloudformation describe-stacks --stack-name ${file%.yaml} --query Stacks[].Outputs[2].OutputValue --output text )"
export HostedZoneId="$( aws route53 list-hosted-zones-by-name | jq --arg name "$DomainName." --raw-output '.HostedZones | .[] | select(.Name=="\($name)") | .Id' | cut --delimiter / --field 3 )"
export InfrastructureName="$( jq --raw-output .infraID $dir/metadata.json )"

# Creating networking and load balancing components in AWS:
file=ocp-route53-$Publish.json
cp -v ${pwd}/${file} ${dir}
sed --in-place s/ClusterName_Value/"$ClusterName"/ $dir/$file
sed --in-place s/HostedZoneId_Value/"$HostedZoneId"/ $dir/$file
sed --in-place s/HostedZoneName_Value/"$DomainName"/ $dir/$file
sed --in-place s/InfrastructureName_Value/"$InfrastructureName"/ $dir/$file
sed --in-place s/Publish_Value/"$Publish"/ $dir/$file
sed --in-place s/PrivateSubnets_Value/"$PrivateSubnets"/ $dir/$file
sed --in-place s/VpcId_Value/"$VpcId"/ $dir/$file
test $Publish = External && sed --in-place s/PublicSubnets_Value/"$PublicSubnets"/ $dir/$file
file=${file%.json}.yaml
cp -v ${pwd}/${file} ${dir}
aws cloudformation create-stack --stack-name ${file%.yaml} --template-body file://$dir/$file --parameters file://$dir/${file%.yaml}.json --capabilities CAPABILITY_NAMED_IAM
cd $dir

# Once the stack creation is completed you can get the following values:
aws cloudformation wait stack-create-complete --stack-name ${file%.yaml}
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

# Creating security group and roles in AWS:
file=ocp-roles.json
cp -v ${pwd}/${file} ${dir}
sed --in-place s/InfrastructureName_Value/"$InfrastructureName"/ $dir/$file
sed --in-place s/PrivateSubnets_Value/"$PrivateSubnets"/ $dir/$file
sed --in-place s/VpcCidr_Value/"$( echo $VpcCidr | sed 's/\//\\\//g' )"/ $dir/$file
sed --in-place s/VpcId_Value/"$VpcId"/ $dir/$file
file=${file%.json}.yaml
cp -v ${pwd}/${file} ${dir}
aws cloudformation create-stack --stack-name ${file%.yaml} --template-body file://$dir/$file --parameters file://$dir/${file%.yaml}.json --capabilities CAPABILITY_NAMED_IAM
cd $dir

# Once the stack creation is completed you can get the following values:
aws cloudformation wait stack-create-complete --stack-name ${file%.yaml}
export MasterInstanceProfileName=$( aws cloudformation describe-stacks --stack-name ${file%.yaml} --query Stacks[].Outputs[1].OutputValue --output text )
export MasterSecurityGroupId=$( aws cloudformation describe-stacks --stack-name ${file%.yaml} --query Stacks[].Outputs[0].OutputValue --output text )
export WorkerInstanceProfileName=$( aws cloudformation describe-stacks --stack-name ${file%.yaml} --query Stacks[].Outputs[3].OutputValue --output text )
export WorkerSecurityGroupId=$( aws cloudformation describe-stacks --stack-name ${file%.yaml} --query Stacks[].Outputs[2].OutputValue --output text )

# Creating the bootstrap node in AWS:
export AllowedBootstrapSshCidr=0.0.0.0/0
export AutoRegisterELB=yes
export BootstrapIgnitionLocation=s3://$InfrastructureName/bootstrap.ign
export PublicSubnet=$( echo $PublicSubnets | cut --delimiter , --field 1 )
export RhcosAmi=$( openshift-install coreos print-stream-json | jq -r '.architectures.'$(arch)'.images.aws.regions["'$(aws configure get region)'"].image' )
aws s3 mb s3://$InfrastructureName
aws s3 cp $dir/bootstrap.ign $BootstrapIgnitionLocation
aws s3 ls s3://$InfrastructureName/
file=ocp-bootstrap-$Publish.json
cp -v ${pwd}/${file} ${dir}
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
cp -v ${pwd}/${file} ${dir}
aws cloudformation create-stack --stack-name ${file%.yaml} --template-body file://$dir/$file --parameters file://$dir/${file%.yaml}.json --capabilities CAPABILITY_NAMED_IAM
aws cloudformation wait stack-create-complete --stack-name ${file%.yaml}
cd $dir

# Creating the control plane machines in AWS:
export AutoRegisterDNS=yes
export PrivateHostedZoneName=$ClusterName.$DomainName
export Master0Subnet=$( echo $PrivateSubnets | cut --delimiter , --field 1 )
export Master1Subnet=$( echo $PrivateSubnets | cut --delimiter , --field 2 )
export Master2Subnet=$( echo $PrivateSubnets | cut --delimiter , --field 3 )
export IgnitionLocation=https://api-int.$PrivateHostedZoneName:22623/config/master
export CertificateAuthorities=$( jq .ignition.security.tls.certificateAuthorities[0].source --raw-output $dir/master.ign )
export MasterInstanceType=${master_type}
file=ocp-master-$Publish.json
cp -v ${pwd}/${file} ${dir}
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
cp -v ${pwd}/${file} ${dir}
aws cloudformation create-stack --stack-name ${file%.yaml} --template-body file://$dir/$file --parameters file://$dir/${file%.yaml}.json
aws cloudformation wait stack-create-complete --stack-name ${file%.yaml}
cd $dir

# Once both stack creations are completed you can initialize the bootstrap node on AWS with user-provisioned infrastructure:
openshift-install-$version wait-for bootstrap-complete --dir $dir --log-level debug
cd $dir

# Creating the worker nodes in AWS:
export IgnitionLocation=https://api-int.$PrivateHostedZoneName:22623/config/worker
export CertificateAuthorities=$( jq .ignition.security.tls.certificateAuthorities[0].source --raw-output $dir/worker.ign )
export WorkerInstanceType=${worker_type}
export Worker0Subnet=$( echo $PrivateSubnets | cut --delimiter , --field 1 )
export Worker1Subnet=$( echo $PrivateSubnets | cut --delimiter , --field 2 )
export Worker2Subnet=$( echo $PrivateSubnets | cut --delimiter , --field 3 )
file=ocp-worker.json
cp -v ${pwd}/${file} ${dir}
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
cp -v ${pwd}/${file} ${dir}
aws cloudformation create-stack --stack-name ${file%.yaml} --template-body file://$dir/$file --parameters file://$dir/${file%.yaml}.json
aws cloudformation wait stack-create-complete --stack-name ${file%.yaml}
cd $dir

# Logging in to the cluster:
export KUBECONFIG=$dir/auth/kubeconfig

# Approving the CSRs for your machines:
oc get csr -o go-template='{{range .items}}{{if not .status}}{{.metadata.name}}{{"\n"}}{{end}}{{end}}' | xargs oc adm certificate approve

# Watch the cluster components come online:
while true;do
  oc get co --no-headers|awk '{print $3}'|grep True  -q&&oc get co --no-headers|awk '{print $3}'|grep -vE "AVAILABLE|True"||break;
  oc get co;
  sleep 10;
done;
while true;do
  oc get co --no-headers|awk '{print $4}'|grep False -q&&oc get co --no-headers|awk '{print $4}'|grep -vE "PROGRESSING|False"||break;
  oc get co;
  sleep 10;
done;
while true;do
  oc get co --no-headers|awk '{print $5}'|grep False -q&&oc get co --no-headers|awk '{print $5}'|grep -vE "DEGRADED|False"||break;
  oc get co;
  sleep 10;
done

# After you complete the initial Operator configuration for the cluster, remove the bootstrap resources from Amazon Web Services (AWS):
aws cloudformation delete-stack --stack-name ocp-bootstrap-$Publish

# Creating the Ingress DNS Records:
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

# Completing the AWS installation on user-provisioned infrastructure:
openshift-install-$version wait-for install-complete --dir $dir --log-level debug
cd $dir



openshift-install-${version} create cluster --dir ${dir} --log-level debug

export KUBECONFIG=${dir}/auth/kubeconfig

oc create secret generic htpass-secret --from-file=htpasswd=users.htpasswd -n openshift-config
oc apply -f oauth.yaml
oc adm policy add-cluster-role-to-user cluster-admin root
