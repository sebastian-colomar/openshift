1. https://access.redhat.com/documentation/en-us/red_hat_quay/3.3/
1. https://access.redhat.com/documentation/en-us/red_hat_quay/3.3/html-single/deploy_red_hat_quay_on_openshift_with_quay_operator/index
1. https://access.redhat.com/documentation/en-us/red_hat_quay/3.3/html-single/deploy_red_hat_quay_on_openshift/index
1. https://access.redhat.com/documentation/en-us/red_hat_quay/3.3/html/deploy_red_hat_quay_on_openshift_with_quay_operator/customizing_your_red_hat_quay_cluster
1. https://access.redhat.com/documentation/en-us/red_hat_quay/3.3/html/deploy_red_hat_quay_on_openshift_with_quay_operator/configuration_deployment_after_initial_setup
1. https://access.redhat.com/documentation/en-us/red_hat_quay/3.3/html/manage_red_hat_quay/using-ssl-to-protect-quay
1. https://access.redhat.com/documentation/en-us/red_hat_quay/3.3/html/manage_red_hat_quay/adding-tls-certificates-to-the-quay-enterprise-container
1. https://access.redhat.com/documentation/en-us/red_hat_quay/3.3/html/manage_red_hat_quay/quay-security-scanner
1. https://access.redhat.com/documentation/en-us/red_hat_quay/3.3/html/manage_red_hat_quay/clair-initial-setup
1. https://access.redhat.com/documentation/en-us/red_hat_quay/3.3/html/manage_red_hat_quay/container-security-operator-setup
1. https://access.redhat.com/documentation/en-us/red_hat_quay/3.3/html/manage_red_hat_quay/quay-bridge-operator
1. https://access.redhat.com/documentation/en-us/red_hat_quay/3.3/html/manage_red_hat_quay/repo-mirroring-in-red-hat-quay
1. https://access.redhat.com/documentation/en-us/red_hat_quay/3.3/html/manage_red_hat_quay/ldap-authentication-setup-for-quay-enterprise
1. https://access.redhat.com/documentation/en-us/red_hat_quay/3.3/html-single/red_hat_quay_api_guide/index
1. https://access.redhat.com/solutions/3498981
1. https://www.linode.com/docs/databases/postgresql/how-to-back-up-your-postgresql-database
   ```
   pg_dump quay > quay.sql
   pg_dumpall > quay_all.sql
   pg_dump clair > clair.sql
   pg_dumpall > clair_all.sql
   
   dropdb quay
   createdb quay
   psql quay < quay.sql
   
   dropdb clair
   createdb clair
   psql clair < clair.sql
   
   psql -f quay_all.sql postgres
   psql -f clair_all.sql postgres
   
   
   ```
   1. https://github.com/secobau/openshift/blob/master/install/backup-quay-clair.md
   
