echo ${ClusterName}
echo ${dir}
echo ${DomainName}
echo ${EmailAddress}

mkdir --parents ${dir}/certs/

export EmailAddress=sebastian.colomar@gmail.com
sudo docker run --interactive --rm --tty --volume ${HOME}/.aws/credentials:/root/.aws/credentials --volume ${dir}/certs/:/etc/letsencrypt/ docker.io/certbot/dns-route53:latest certonly -n --dns-route53 --agree-tos --email ${EmailAddress} -d *.apps.${ClusterName}.${DomainName}

sudo chown $( id -un ):$( id -gn ) -R ${dir}/certs/
mkdir --parents ${dir}/tls/apps/
cp -f ${dir}/certs/live/apps.${ClusterName}.${DomainName}/*.pem ${dir}/tls/apps/

oc create configmap custom-ca --from-file=ca-bundle.crt=${dir}/tls/apps/fullchain.pem --namespace openshift-config

oc patch proxy/cluster --patch '{"spec":{"trustedCA":{"name":"custom-ca"}}}' --type=merge

oc create secret tls certificate --cert=${dir}/tls/apps/fullchain.pem --key=${dir}/tls/apps/privkey.pem --namespace openshift-ingress

oc patch ingresscontroller.operator default --namespace openshift-ingress-operator --patch '{"spec":{"defaultCertificate": {"name": "certificate"}}}' --type=merge

export EmailAddress=sebastian.colomar@gmail.com
sudo docker run --interactive --rm --tty --volume ${HOME}/.aws/credentials:/root/.aws/credentials --volume ${dir}/certs/:/etc/letsencrypt/ docker.io/certbot/dns-route53:latest certonly -n --dns-route53 --agree-tos --email ${EmailAddress} -d *.apps-int.${ClusterName}.${DomainName}

sudo chown $( id -un ):$( id -gn ) -R ${dir}/certs/
mkdir --parents ${dir}/tls/apps-int/
cp -f ${dir}/certs/live/apps-int.${ClusterName}.${DomainName}/*.pem ${dir}/tls/apps-int/

oc create secret tls certificate-internal --cert=${dir}/tls/apps/fullchain.pem --key=${dir}/tls/apps/privkey.pem --namespace openshift-ingress

oc apply -f - <<EOF
apiVersion: operator.openshift.io/v1
kind: IngressController
metadata:
  name: internal
  namespace: openshift-ingress-operator
spec:
  defaultCertificate:
    name: certificate-internal
  domain: apps-int.${ClusterName}.${DomainName}
  endpointPublishingStrategy:
    loadBalancer:
      scope: Internal
    type: LoadBalancerService
  replicas: 2
  routeSelector:
    matchLabels:
      ingress-type: internal
EOF

export EmailAddress=sebastian.colomar@gmail.com
sudo docker run --interactive --rm --tty --volume ${HOME}/.aws/credentials:/root/.aws/credentials --volume ${dir}/certs/:/etc/letsencrypt/ docker.io/certbot/dns-route53:latest certonly -n --dns-route53 --agree-tos --email ${EmailAddress} -d api.${ClusterName}.${DomainName}

sudo chown $( id -un ):$( id -gn ) -R ${dir}/certs/
mkdir --parents ${dir}/tls/api/
cp -f ${dir}/certs/live/api.${ClusterName}.${DomainName}/*.pem ${dir}/tls/api/

oc create secret tls certificate --cert=${dir}/tls/api/fullchain.pem --key=${dir}/tls/api/privkey.pem --namespace openshift-config

oc patch apiserver cluster --patch '{"spec":{"servingCerts":{"namedCertificates":[{"names":["api.'${ClusterName}'.'${DomainName}'"],"servingCertificate":{"name":"certificate"}}]}}}' --type=merge

cp -f ${dir}/tls/api/fullchain.pem ${dir}/auth
sed --in-place s/certificate-authority-data.*$/certificate-authority:' 'fullchain.pem/ ${dir}/auth/kubeconfig


