export EmailAddress=sebastian.colomar@gmail.com
docker run -it --rm -v ~/.aws/credentials:/root/.aws/credentials -v ~/environment/certs:/etc/letsencrypt certbot/dns-route53 certonly -n --dns-route53 --agree-tos --email $EmailAddress -d *.apps.$ClusterName.$DomainName

sudo chown $USER. -R ~/environment/certs
test -d $dir/tls/ || mkdir $dir/tls/
cp ~/environment/certs/live/apps.$ClusterName.$DomainName/*.pem $dir/tls/

oc create configmap custom-ca --from-file=ca-bundle.crt=$dir/tls/fullchain.pem -n openshift-config

oc patch proxy/cluster --type=merge --patch='{"spec":{"trustedCA":{"name":"custom-ca"}}}'

oc create secret tls certificate --cert=$dir/tls/fullchain.pem --key=$dir/tls/privkey.pem -n openshift-ingress

oc patch ingresscontroller.operator default --type=merge -p '{"spec":{"defaultCertificate": {"name": "certificate"}}}' -n openshift-ingress-operator

export EmailAddress=sebastian.colomar@gmail.com
docker run -it --rm -v ~/.aws/credentials:/root/.aws/credentials -v ~/environment/certs:/etc/letsencrypt certbot/dns-route53 certonly -n --dns-route53 --agree-tos --email $EmailAddress -d api.$ClusterName.$DomainName  

sudo chown $USER. -R ~/environment/certs
test -d $dir/tls/ || mkdir $dir/tls/
cp ~/environment/certs/live/api.$ClusterName.$DomainName/*.pem $dir/tls/

oc create secret tls certificate --cert=$dir/tls/fullchain.pem --key=$dir/tls/privkey.pem -n openshift-config

oc patch apiserver cluster --type=merge -p '{"spec":{"servingCerts":{"namedCertificates":[{"names":["api.'$ClusterName'.'$DomainName'"],"servingCertificate":{"name":"certificate"}}]}}}'

cp $dir/tls/fullchain.pem $dir/auth
sed -i s/certificate-authority-data.*$/certificate-authority:' 'fullchain.pem/ $dir/auth/kubeconfig


