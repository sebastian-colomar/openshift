In order to substitute the self-signed certificate by a valid one:
* https://docs.openshift.com/container-platform/4.5/authentication/certificates/replacing-default-ingress-certificate.html
  
  1. If you need to generate LetsEncrypt certificates you can run this script:
  ```bash
  export EmailAddress=sebastian.colomar@gmail.com
  docker run -it --rm -v ~/.aws/credentials:/root/.aws/credentials -v ~/environment/certs:/etc/letsencrypt certbot/dns-route53 certonly -n --dns-route53 --agree-tos --email $EmailAddress -d *.apps.$ClusterName.$DomainName
  ```
  ```bash
  sudo chown $USER. -R ~/environment/certs
  test -d $dir/tls/ || mkdir $dir/tls/
  cp ~/environment/certs/live/apps.$ClusterName.$DomainName/*.pem $dir/tls/
  ```
  2. Create a ConfigMap that includes the certificate authority used to sign the new certificate:
  ```bash
  oc create configmap custom-ca --from-file=ca-bundle.crt=$dir/tls/fullchain.pem -n openshift-config
  ```
  3. Update the cluster-wide proxy configuration with the newly created ConfigMap:
  ```bash
  oc patch proxy/cluster --type=merge --patch='{"spec":{"trustedCA":{"name":"custom-ca"}}}'
  ```
  4. Create a secret that contains the wildcard certificate and key:
  ```bash
  oc create secret tls certificate --cert=$dir/tls/fullchain.pem --key=$dir/tls/privkey.pem -n openshift-ingress
  ```
  5. Update the Ingress Controller configuration with the newly created secret:
  ```bash
  oc patch ingresscontroller.operator default --type=merge -p '{"spec":{"defaultCertificate": {"name": "certificate"}}}' -n openshift-ingress-operator
  ```

* https://docs.openshift.com/container-platform/4.5/authentication/certificates/api-server.html

  1. If you need to generate LetsEncrypt certificates you can run this script:
  ```bash
  export EmailAddress=sebastian.colomar@gmail.com
  docker run -it --rm -v ~/.aws/credentials:/root/.aws/credentials -v ~/environment/certs:/etc/letsencrypt certbot/dns-route53 certonly -n --dns-route53 --agree-tos --email $EmailAddress -d api.$ClusterName.$DomainName  
  ```
  ```bash
  sudo chown $USER. -R ~/environment/certs
  test -d $dir/tls/ || mkdir $dir/tls/
  cp ~/environment/certs/live/api.$ClusterName.$DomainName/*.pem $dir/tls/
  ```
  2. Create a secret that contains the certificate and key in the openshift-config namespace.
  ```bash
  oc create secret tls certificate --cert=$dir/tls/fullchain.pem --key=$dir/tls/privkey.pem -n openshift-config
  ```
  3. Update the API server to reference the created secret.
  ```bash
  oc patch apiserver cluster --type=merge -p '{"spec":{"servingCerts":{"namedCertificates":[{"names":["api.'$ClusterName'.'$DomainName'"],"servingCertificate":{"name":"certificate"}}]}}}'
  ```
  4. https://stackoverflow.com/questions/46234295/kubectl-unable-to-connect-to-server-x509-certificate-signed-by-unknown-authori/63518617#63518617
  ```bash
  Unable to connect to the server: x509: certificate signed by unknown authority
  ```
  5. To solve the previous issue with the new API certificate:
  ```bash
  cp $dir/tls/fullchain.pem $dir/auth
  sed -i s/certificate-authority-data.*$/certificate-authority:' 'fullchain.pem/ $dir/auth/kubeconfig
  ```
