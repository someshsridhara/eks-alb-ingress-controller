#!/bin/bash
set -e

echo "Getting policies available to check if the policy being created already exists.."

POLICY_COUNT=`aws iam list-policies | grep $POLICY_NAME | wc -l`

if [ $POLICY_COUNT -gt "0" ]; then
    echo "Policy exists skipping creation";
    exit;
else
    echo "Creating policy as it doesnt exist.."
    POLICY_ARN=`aws iam create-policy \
    --policy-name AWSLoadBalancerControllerIAMPolicy \
    --policy-document file://templates/iam-policy.json | jq -r '.Policy.Arn'`;
    echo $POLICY_ARN;
fi

echo "Creating IAM role.."
ROLE_ARN=`aws iam create-role --role-name eks-alb-ingress-controller --assume-role-policy-document file://templates/trust.json | jq -r '.Role.Arn'`

echo "Attaching policy.. "
aws iam attach-role-policy --role-name eks-alb-ingress-controller --policy-arn=$POLICY_ARN
aws iam attach-role-policy --role-name eks-alb-ingress-controller --policy-arn arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy
aws iam attach-role-policy --role-name eks-alb-ingress-controller --policy-arn arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy

echo "Annotating the ingress controller service account"
kubectl annotate serviceaccount -n kube-system alb-ingress-controller \
eks.amazonaws.com/role-arn=$ROLE_ARN