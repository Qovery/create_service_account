#!/bin/bash

set -e

JOB_ACTION=$1

echo "-> Ensuring required environment variables are present"
all_required_env_vars=(SERVICE_ACCOUNT_NAME QOVERY_KUBERNETES_NAMESPACE_NAME QOVERY_KUBERNETES_CLUSTER_NAME QOVERY_CLOUD_PROVIDER_REGION AWS_ROLE_ARN)
for env_var in ${all_required_env_vars[@]}; do
  if [[ -z ${!env_var+x} ]] ; then
      echo "Environment variable $env_var is missing"
      exit 1
  fi
done

echo "-> Downloading kubectl version $KUBERNETES_VERSION"
curl -sLO https://dl.k8s.io/release/v$KUBERNETES_VERSION/bin/linux/amd64/kubectl || exit 1
mv kubectl /usr/bin/ && chmod 755 /usr/bin/kubectl

cat << EOF > sa.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
 name: $SERVICE_ACCOUNT_NAME
 namespace: $QOVERY_KUBERNETES_NAMESPACE_NAME
 annotations:
   eks.amazonaws.com/role-arn: $AWS_ROLE_ARN
EOF

echo -e "-> Generated service account:\n$(cat sa.yaml)"

echo "-> Getting kubeconfig"
aws eks update-kubeconfig --region $QOVERY_CLOUD_PROVIDER_REGION --name $QOVERY_KUBERNETES_CLUSTER_NAME

case "$JOB_ACTION" in
    "start")
        echo "-> Deploying service account"
        kubectl apply -f sa.yaml
        ;;
    "delete")
        echo "-> Deleting service account"
        kubectl delete -f sa.yaml
        ;;
    *)
        echo "-> Unssuported job action: '$JOB_ACTION'. Only 'start' and 'delete' are supported"
        echo 'Please check the tutorial: https://hub.qovery.com/guides/tutorial/use-aws-iam-roles-with-qovery/#create-a-lifecycle-job'
        exit 1
        ;;
esac
