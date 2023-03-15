set -x

pwd=${PWD}
source 00-env.sh
source 01-initial.sh

cd ${pwd}
source 02-create.sh
source 03-certs.sh
cd ${dir}

set +x
