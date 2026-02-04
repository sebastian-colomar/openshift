export ClusterName=openshift
export DomainName=sebastian-colomar.es 
export master_type=t3a.xlarge
export Publish=External
export version=4.8.33
export worker_type=t3a.large

# openshift-install-4.8.33 coreos print-stream-json | tee stream.json
# jq -r '.architectures.x86_64.images.aws.regions | to_entries[] | "\(.key) \(.value.image)"' stream.json | sort | tee regions_amis.txt
# while read -r region ami; do printf "%-15s %-20s : " "$region" "$ami"; aws ec2 describe-images --region "$region" --image-ids "$ami" --query 'Images[0].State' --output text 2>/dev/null | grep -q available && echo "AVAILABLE" || echo "NOT FOUND"; done < regions_amis.txt
# aws ec2 describe-images --region ap-southeast-1 --image-ids ami-0b574d30ee267107c
# aws ec2 copy-image --source-region ap-southeast-1 --source-image-id ami-0b574d30ee267107c --region ap-south-1 --name "rhcos-48.84.202109241901-0"
# {
#     "ImageId": "ami-0e1b098ff482299d5"
# }
# aws ec2 describe-images --region ap-south-1 --image-ids ami-0e1b098ff482299d5
export amiID=ami-0e1b098ff482299d5
