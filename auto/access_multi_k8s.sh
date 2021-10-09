#!/bin/bash 
mkdir .kube

# download each kubeconfig file with scp
HOST_PREFIX="kk-"
FIRST_CLUSTER_MASTER="${HOST_PREFIX}k8s-master"
FIRST_CLUSTER_WORKER1="${HOST_PREFIX}k8s-worker1"
SECOND_CLUSTER_MASTER="${HOST_PREFIX}hk8s-master"
SECOND_CLUSTER_WORKER1="${HOST_PREFIX}hk8s-worker1"

ssh FIRST_CLUSTER_MASTER "sudo cat ~root/join_token" > k8s-master-join
ssh FIRST_CLUSTER_WORKER1 "sudo $( cat ./k8s-master-join)"
ssh SECOND_CLUSTER_MASTER "sudo cat ~root/join_token" > hk8s-master-join
ssh FIRST_CLUSTER_WORKER1 "sudo $( cat ./hk8s-master-join)"

scp ${FIRST_CLUSTER_MASTER}:~/kubeconfig ~/.kube/config1
scp ${SECOND_CLUSTER_MASTER}:~/kubeconfig ~/.kube/config2


# retrieve cert files (ca.crt, admin.pub, admin.key) from 2'nd cluster kubeconfig file
cd .kube
cat config2 | yq e '.clusters[0].cluster.certificate-authority-data' - | base64 -d > ca.crt
cat config2 | yq e '.users[0].user.client-certificate-data' - | base64 -d > admin.pub
cat config2 | yq e '.users[0].user.client-key-data' - | base64 -d > admin.key


# add 2'nd cluster info first cluster config 파일(config1) 
# set 2'nd cluster address and ca file
echo "set 2'nd cluster address and ca file to first cluster kubeconfig file"
kubectl config --embed-certs=true --kubeconfig=config1 set-cluster hk8s-cluster --server=https://${SECOND_CLUSTER_MASTER}:6443 --certificate-authority=./ca.crt 

# add 2'nd user to first cluster kubeconfig file"
echo "add 2'nd user to first cluster kubeconfig file"
kubectl config --embed-certs=true --kubeconfig=config1 set-credentials hk8s-admin --client-certificate=./admin.pub --client-key=./admin.key

# set 2'nd context to first cluster kubeconfig file
echo "set 2'nd context to first cluster kubeconfig file"
kubectl config --kubeconfig=config1 set-context hk8s-admin --cluster=hk8s-cluster --user=hk8s-admin

# copy first cluster kubeconfig file into default directory
echo "copy first cluster kubeconfig file into default directory"
cp config1 ~/.kube/config