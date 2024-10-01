openshift-baremetal-install --dir ~/clusterconfigs --log-level debug destroy cluster

source ./wipe.sh
source ./bmc-secureboot-disable.sh
source ./bmc-secureboot-status.sh|grep -E ".SecureBootCurrentBoot.:.Disabled.|.SecureBootEnable.:false" -B1
source ./bmc-poweroff.sh

source ./virsh-remove.sh
source ./pull-release.sh
source ./install-config_ipmi.sh

podman rm -f rhcos_image_cache
podman run -d --name rhcos_image_cache -p 8080:8080/tcp -v /home/kni/rhcos_image_cache:/var/www/html registry.access.redhat.com/ubi9/httpd-24

openshift-baremetal-install --dir ~/clusterconfigs --log-level debug create manifests
openshift-baremetal-install --dir ~/clusterconfigs --log-level debug create cluster

source ./wait-for-no-co.sh
source ./secureboot-reenable.sh
