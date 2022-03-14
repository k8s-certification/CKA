#!/bin/bash

mkdir .kube && touch .kube/config

# download each kubeconfig file with scp
HOST_PREFIX=""
FIRST_CLUSTER_MASTER="${HOST_PREFIX}k8s-master"
FIRST_CLUSTER_WORKER1="${HOST_PREFIX}k8s-worker1"
SECOND_CLUSTER_MASTER="${HOST_PREFIX}hk8s-master"
SECOND_CLUSTER_WORKER1="${HOST_PREFIX}hk8s-worker1"

# cluster join
ssh ${FIRST_CLUSTER_MASTER} "sudo  cat ~root/join_token"  > k8s-master-join
ssh ${FIRST_CLUSTER_WORKER1} "sudo  $( cat ./k8s-master-join)"
ssh ${SECOND_CLUSTER_MASTER} "sudo  cat ~root/join_token"  > hk8s-master-join
ssh ${SECOND_CLUSTER_WORKER1} "sudo  $( cat ./hk8s-master-join)"


scp ${FIRST_CLUSTER_MASTER}:~/kubeconfig ~/.kube/config1
scp ${SECOND_CLUSTER_MASTER}:~/kubeconfig ~/.kube/config2


# retrieve cert files (ca2.crt, admin2.pub, admin2.key) from 2'nd cluster kubeconfig file
cd .kube

cat config1 | yq e '.clusters[0].cluster.certificate-authority-data' - | base64 -d > ca1.crt
cat config1 | yq e '.users[0].user.client-certificate-data' - | base64 -d > admin1.pub
cat config1 | yq e '.users[0].user.client-key-data' - | base64 -d > admin1.key


echo "set First cluster address and ca file to first cluster kubeconfig file"
kubectl config --embed-certs=true --kubeconfig=config set-cluster k8s-cluster --server=https://${FIRST_CLUSTER_MASTER}:6443 --certificate-authority=./ca1.crt

echo "add First user to first cluster kubeconfig file"
kubectl config --embed-certs=true --kubeconfig=config set-credentials k8s-admin --client-certificate=./admin1.pub --client-key=./admin1.key

echo "set First context to first cluster kubeconfig file"
kubectl config --kubeconfig=config set-context k8s --cluster=k8s-cluster --user=k8s-admin



cat config2 | yq e '.clusters[0].cluster.certificate-authority-data' - | base64 -d > ca2.crt
cat config2 | yq e '.users[0].user.client-certificate-data' - | base64 -d > admin2.pub
cat config2 | yq e '.users[0].user.client-key-data' - | base64 -d > admin2.key


# add 2'nd cluster info first cluster config 파일(config1)
# set 2'nd cluster address and ca file
echo "set 2'nd cluster address and ca file to first cluster kubeconfig file"
kubectl config --embed-certs=true --kubeconfig=config set-cluster hk8s-cluster --server=https://${SECOND_CLUSTER_MASTER}:6443 --certificate-authority=./ca2.crt

# add 2'nd user to first cluster kubeconfig file"
echo "add 2'nd user to first cluster kubeconfig file"
kubectl config --embed-certs=true --kubeconfig=config set-credentials hk8s-admin --client-certificate=./admin2.pub --client-key=./admin2.key

# set 2'nd context to first cluster kubeconfig file
echo "set 2'nd context to first cluster kubeconfig file"
kubectl config --kubeconfig=config set-context hk8s --cluster=hk8s-cluster --user=hk8s-admin

echo "COMPLETE!! Now current-context is k8s-master"
kubectl config use-context k8s
