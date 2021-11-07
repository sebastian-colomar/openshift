export EmailAddress=sebastian.colomar@gmail.com
docker run --interactive --rm --tty --volume ${HOME}/.aws/credentials:/root/.aws/credentials --volume ${HOME}/environment/certs:/etc/letsencrypt certbot/dns-route53 certonly -n --dns-route53 --agree-tos --email ${EmailAddress} -d *.apps.${ClusterName}.${DomainName}

sudo chown ${USER}. -R ${HOME}/environment/certs
mkdir --parents ${dir}/tls/
cp {HOME}/environment/certs/live/apps.${ClusterName}.${DomainName}/*.pem ${dir}/tls/

oc create configmap custom-ca --from-file=ca-bundle.crt=${dir}/tls/fullchain.pem --namespace openshift-config

oc patch proxy/cluster --patch '{"spec":{"trustedCA":{"name":"custom-ca"}}}' --type=merge

oc create secret tls certificate --cert=${dir}/tls/fullchain.pem --key=${dir}/tls/privkey.pem --namespace openshift-ingress

oc patch ingresscontroller.operator default --namespace openshift-ingress-operator --patch '{"spec":{"defaultCertificate": {"name": "certificate"}}}' --type=merge

export EmailAddress=sebastian.colomar@gmail.com
docker run --interactive --rm --tty --volume ${HOME}/.aws/credentials:/root/.aws/credentials --volume ${HOME}/environment/certs:/etc/letsencrypt certbot/dns-route53 certonly -n --dns-route53 --agree-tos --email ${EmailAddress} -d api.${ClusterName}.${DomainName}  

sudo chown $USER. -R {HOME}/environment/certs
mkdir --parents ${dir}/tls/
cp ${HOME}/environment/certs/live/api.${ClusterName}.${DomainName}/*.pem ${dir}/tls/

oc create secret tls certificate --cert=${dir}/tls/fullchain.pem --key=${dir}/tls/privkey.pem --namespace openshift-config

oc patch apiserver cluster --patch '{"spec":{"servingCerts":{"namedCertificates":[{"names":["api.'$ClusterName'.'$DomainName'"],"servingCertificate":{"name":"certificate"}}]}}}' --type=merge

cp ${dir}/tls/fullchain.pem ${dir}/auth
sed --in-place s/certificate-authority-data.*$/certificate-authority:' 'fullchain.pem/ ${dir}/auth/kubeconfig


