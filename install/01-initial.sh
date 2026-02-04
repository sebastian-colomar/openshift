test -f ${HOME}/.ssh/id_rsa.pub || ssh-keygen -f ${HOME}/.ssh/id_rsa -P ''
eval "$( ssh-agent -s )"
ssh-add ${HOME}/.ssh/id_rsa 

export BINARY_PATH=${HOME}/bin
grep -q ":${BINARY_PATH}:" ~/.bashrc || echo "export PATH=\"${BINARY_PATH}:\${PATH}\"" | tee -a ~/.bashrc
source ~/.bashrc


if ! test -f ${BINARY_PATH}/bin/openshift-install-${version}
then
modes='client install'
for mode in ${modes}
  do
    curl -O https://mirror.openshift.com/pub/openshift-v4/clients/ocp/${version}/openshift-${mode}-linux-${version}.tar.gz
    gunzip openshift-${mode}-linux-${version}.tar.gz
    tar xf openshift-${mode}-linux-${version}.tar
    rm openshift-${mode}-linux-${version}.tar
  done

mkdir -p ${BINARY_PATH}

binaries='kubectl oc'
for binary in ${binaries}
  do
    mv ${binary} ${BINARY_PATH}
  done
mv openshift-install ${BINARY_PATH}/openshift-install-${version}

file=README.md 
test -f ${file} && rm -f ${file}

file=${BINARY_PATH}/openshift-install
test -f ${file} && rm -f ${file}

ln -s ${BINARY_PATH}/openshift-install-${version} ${BINARY_PATH}/openshift-install
rm ${BINARY_PATH}/kubectl && ln -s ${BINARY_PATH}/oc ${BINARY_PATH}/kubectl    
fi

export dir="${HOME}/environment/${ClusterName}.${DomainName}"
test -d ${dir} || mkdir -p ${dir} 

openshift-install-${version} create install-config --dir ${dir} --log-level debug

cd ${dir} && git init
git config --global user.name 'Your Name'
git config --global user.email you@example.com
git add .
git commit -m Initial 

cd ${dir}
cp -v ${pwd}/fix-config.sh .
chmod +x fix-config.sh && ./fix-config.sh && rm fix-config.sh
git commit -am 'Set EC2 instance type' 


