```
INSTALL AND CONFIGURE OC AND KUBECTL

1. DOWNLOAD THE OPENSHIFT CLI

Download the oc binary for your operating system:

Windows:
https://downloads-openshift-console.apps.k8s.sebastian-colomar.es/amd64/windows/oc.zip

macOS (Intel):
https://downloads-openshift-console.apps.k8s.sebastian-colomar.es/amd64/mac/oc.zip

Linux (AMD64):
https://downloads-openshift-console.apps.k8s.sebastian-colomar.es/amd64/linux/oc.tar

Extract the downloaded ZIP or TAR archive to obtain the oc executable.


2. LOG IN TO THE KUBERNETES CLUSTER

Open a terminal in the directory containing the oc executable.

On Linux or macOS, run:

./oc login https://api.k8s.sebastian-colomar.es:6443 -u user

Enter your password when prompted.

On Windows, use oc.exe instead of ./oc.


3. CREATE THE KUBECTL EXECUTABLE

The oc binary supports standard Kubernetes commands and can also be used as kubectl.

On Linux or macOS, run:

cp oc kubectl
chmod +x kubectl

On Windows, copy oc.exe and rename the copy to kubectl.exe.


4. CONFIGURE AN ALIAS (OPTIONAL)

On Linux or macOS, you can create an alias to use the downloaded binary without typing ./ each time.

Run:

alias kubectl='./kubectl'

You can now execute commands such as:

kubectl get all
kubectl get nodes
kubectl get pods -A

Note that this alias works only when you are in the directory containing the kubectl executable.

The alias is temporary and applies only to the current terminal session.

To make it persistent, add it to your shell configuration file, such as ~/.bashrc or ~/.zshrc.


5. RUN KUBERNETES COMMANDS

Without an alias, run:

./kubectl get all

Other useful commands:

./kubectl get nodes
./kubectl get pods -A
./kubectl get namespaces

If you configured the alias, you can omit ./ from these commands.


6. OPTIONAL: ADD THE EXECUTABLES TO YOUR PATH

Alternatively, you can move both oc and kubectl to a directory included in your system's PATH.

This allows you to execute Kubernetes commands from any directory without using ./ or configuring an alias.

Examples:

kubectl get all
kubectl get nodes
kubectl get pods -A


NOTE:

Both oc and kubectl use the same Kubernetes configuration and authentication credentials.

You only need to log in once, provided both commands use the same kubeconfig file.
```
