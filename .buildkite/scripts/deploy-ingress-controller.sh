#!/bin/bash
set -e

helm repo add eks https://aws.github.io/eks-charts
kubectl apply -k "github.com/aws/eks-charts/stable/aws-load-balancer-controller//crds?ref=master"
helm upgrade -i aws-load-balancer-controller eks/aws-load-balancer-controller -n $K8S_NAMESPACE --set clusterName=$K8S_CLUSTER_NAME --set serviceAccount.create=false --set serviceAccount.name=$SERVICE_ACCOUNT_NAME --set autoDiscoverAwsVpcID=true