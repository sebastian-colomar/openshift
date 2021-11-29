mkdir --parents ${dir}/certs/

export EmailAddress=sebastian.colomar@gmail.com
docker run --interactive --rm --tty --volume ${HOME}/.aws/credentials:/root/.aws/credentials --volume ${dir}/certs/:/etc/letsencrypt/ certbot/dns-route53 certonly -n --dns-route53 --agree-tos --email ${EmailAddress} -d *.apps.${ClusterName}.${DomainName}

sudo chown ${USER}. -R ${dir}/certs/
mkdir --parents ${dir}/tls/apps/
cp ${dir}/certs/live/apps.${ClusterName}.${DomainName}/*.pem ${dir}/tls/apps/

oc create configmap custom-ca --from-file=ca-bundle.crt=${dir}/tls/apps/fullchain.pem --namespace openshift-config

oc patch proxy/cluster --patch '{"spec":{"trustedCA":{"name":"custom-ca"}}}' --type=merge

oc create secret tls certificate --cert=${dir}/tls/apps/fullchain.pem --key=${dir}/tls/apps/privkey.pem --namespace openshift-ingress

oc patch ingresscontroller.operator default --namespace openshift-ingress-operator --patch '{"spec":{"defaultCertificate": {"name": "certificate"}}}' --type=merge

export EmailAddress=sebastian.colomar@gmail.com
docker run --interactive --rm --tty --volume ${HOME}/.aws/credentials:/root/.aws/credentials --volume ${dir}/certs/:/etc/letsencrypt/ certbot/dns-route53 certonly -n --dns-route53 --agree-tos --email ${EmailAddress} -d api.${ClusterName}.${DomainName}

sudo chown ${USER}. -R ${dir}/certs/
mkdir --parents ${dir}/tls/api/
cp ${HOME}/environment/certs/live/api.${ClusterName}.${DomainName}/*.pem ${dir}/tls/api/

oc create secret tls certificate --cert=${dir}/tls/api/fullchain.pem --key=${dir}/tls/api/privkey.pem --namespace openshift-config

oc patch apiserver cluster --patch '{"spec":{"servingCerts":{"namedCertificates":[{"names":["api.'${ClusterName}'.'${DomainName}'"],"servingCertificate":{"name":"certificate"}}]}}}' --type=merge

cp ${dir}/tls/api/fullchain.pem ${dir}/auth
sed --in-place s/certificate-authority-data.*$/certificate-authority:' 'fullchain.pem/ ${dir}/auth/kubeconfig


