test -f ${HOME}/.ssh/id_rsa || ssh-keygen -f ${HOME}/.ssh/id_rsa -P ''
eval "$( ssh-agent -s )"
ssh-add ${HOME}/.ssh/id_rsa 

export dir="${HOME}/environment/${ClusterName}.${DomainName}"
test -d ${dir} || mkdir -p ${dir} 

cd ${dir} && git init
git config --global user.name 'Your Name'
git config --global user.email you@example.com
git add .
git commit -m Initial 

if ! test -f ${HOME}/bin/openshift-install-${version}
then

modes='client install'
for mode in ${modes}
  do
    curl -O https://mirror.openshift.com/pub/openshift-v4/clients/ocp/${version}/openshift-${mode}-linux-${version}.tar.gz
    gunzip openshift-${mode}-linux-${version}.tar.gz
    tar xf openshift-${mode}-linux-${version}.tar
    rm -f openshift-${mode}-linux-${version}.tar
  done

binaries='oc openshift-install'
for binary in ${binaries}
  do
    sudo install ${binary} /usr/local/bin/
    rm ${binary}
    rm kubectl
  done
sudo ln -s /usr/local/bin/oc /usr/local/bin/kubectl
sudo ln -s /usr/local/bin/openshift-install /usr/local/bin/openshift-install-${version}

fi

openshift-install-${version} create install-config --dir ${dir} --log-level debug

wget https://raw.githubusercontent.com/academiaonline-org/openshift/master/install/fix-config.sh
chmod +x fix-config.sh && ./fix-config.sh && rm -f fix-config.sh
git commit -am 'Set EC2 instance type' 


