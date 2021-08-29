1. Create a new project:

   `oc new-project quay-enterprise`
1. Install the Red Hat Quay Operator
1. Load credentials to obtain Quay:
   
   `oc get secret -n openshift-config pull-secret -o yaml > registry-pull-secret.yaml`
   
   Modify the secret removing all unnecessary metada and load it again:
   
   `oc apply -n quay-enterprise -f registry-pull-secret.yaml`
1. You will need a specific certificate for the registry:

   ```
   dir=~/environment/quay/tls
   certs=~/environment/certs
   mkdir --parents $dir
   EmailAddress=sebastian.colomar@gmail.com
   docker run -it --rm -v ~/.aws/credentials:/root/.aws/credentials -v $certs:/etc/letsencrypt certbot/dns-route53 certonly -n --dns-route53 --agree-tos --email $EmailAddress -d registry.apps.$ClusterName.$DomainName
   sudo chown $USER. -R $certs
   cp $certs/live/registry.apps.$ClusterName.$DomainName/*.pem $dir
   
   
   ```
1. Create the necessary secrets:

   ```
   oc --namespace quay-enterprise create secret generic registry-admin --from-literal=superuser-username=admin --from-literal=superuser-password=xxx --from-literal=superuser-email=$EmailAddress
   oc --namespace quay-enterprise create secret generic registry-clair --from-literal=database-username=clair --from-literal=database-password=xxx --from-literal=database-root-password=yyy --from-literal=database-name=clair
   oc --namespace quay-enterprise create secret generic registry-config --from-literal=config-app-password=xxx
   oc --namespace quay-enterprise create secret generic registry-quay --from-literal=database-username=quay --from-literal=database-password=xxx --from-literal=database-root-password=yyy --from-literal=database-name=quay
   oc --namespace quay-enterprise create secret generic registry-redis --from-literal=password=xxx
   oc --namespace quay-enterprise create secret generic registry-s3 --from-literal=accessKey=xxx --from-literal=secretKey=yyy
   oc --namespace quay-enterprise create secret tls registry-ssl --key=$dir/privkey.pem --cert=$dir/fullchain.pem
   
   
   ```
1. Please customize the following configuration before applying it:

   `oc apply -f https://raw.githubusercontent.com/secobau/openshift/master/install/quayEcosystem.yaml`   
1. https://access.redhat.com/solutions/3756341
