#!/bin/bash 
# modify CONSOLE_IP if console vm's IP is not following IP (10.128.0.2)
# CONSOLE_IP=10.128.0.2

VM_HOSTNAME=vm_hostname
CONSOLE_HOST_PREFIX="kk-"
CONSOLE_HOST=cka-console
CONSOLE_HOSTNAME="$CONSOLE_HOST_PREFIX$CONSOLE_HOST"
#echo $CONSOLE_HOSTNAME
curl "http://metadata.google.internal/computeMetadata/v1/instance/hostname"  -H "Metadata-Flavor: Google" > $VM_HOSTNAME

#echo $(cat $VM_HOSTNAME )
CONSOLE_Internal_DNS=$(cat $VM_HOSTNAME | awk -F. '{print $2"."$3"."$4"."$5}')
CONSOLE_Internal_DNS="$CONSOLE_HOSTNAME.$CONSOLE_Internal_DNS"


su - ubuntu -c  "curl -LO  http://$CONSOLE_Internal_DNS:8000/id_rsa.pub"
su - ubuntu -c  "cat id_rsa.pub >> ~/.ssh/authorized_keys"


#install k8s-cluster
if [[ `hostname` == *"master"* ]]; then
  /bin/bash <(curl -s  https://raw.githubusercontent.com/killer-sh/cks-course-environment/master/cluster-setup/latest/install_master.sh)
  cp ~/.kube/config ~ubuntu/kubeconfig && chown ubuntu:ubuntu ~ubuntu/kubeconfig

else
  /bin/bash <(curl -s  https://raw.githubusercontent.com/killer-sh/cks-course-environment/master/cluster-setup/latest/install_worker.sh)
  touch ~/end_worker.txt && cp ~/end_worker.txt ~ubuntu/end_worker.txt && chown ubuntu:ubuntu ~ubuntu/end_worker.txt

fi
