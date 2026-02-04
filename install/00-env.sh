export ClusterName=hub
export DomainName=sebastian-colomar.com 
export master_type=t3a.2xlarge
export Publish=External
export version=4.8.37
export worker_type=t3a.2xlarge

# openshift-install-4.8.37 coreos print-stream-json | tee stream.json
# jq -r '.architectures.x86_64.images.aws.regions | to_entries[] | "\(.key) \(.value.image)"' stream.json | sort | tee regions_amis.txt
# while read -r region ami; do printf "%-15s %-20s : " "$region" "$ami"; aws ec2 describe-images --region "$region" --image-ids "$ami" --query 'Images[0].State' --output text 2>/dev/null | grep -q available && echo "AVAILABLE" || echo "NOT FOUND"; done < regions_amis.txt
#     us-east-1       ami-06e6531aef9359b1e : AVAILABLE
# aws ec2 describe-images --region us-east-1 --image-ids ami-06e6531aef9359b1e
# aws ec2 copy-image --source-region us-east-1 --source-image-id ami-06e6531aef9359b1e --region ap-south-1 --name "rhcos-48.84.202109241901-0"
# {
#     "ImageId": "ami-0fab511d32cc88793"
# }
# aws ec2 describe-images --region ap-south-1 --image-ids ami-0fab511d32cc88793
export amiID=ami-0fab511d32cc88793
