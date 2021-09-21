# git clone https://github.com/academiaonline/openshift
# cd openshift
# git checkout master
# cd install
# source ocp-aws-install.sh

pwd=${PWD}
source 00-env.sh
source 01-initial.sh

cd ${pwd}
source 02-create.sh
source 03-certs.sh

