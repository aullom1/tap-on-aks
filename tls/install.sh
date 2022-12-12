echo "Login to Azure cli."
account=$(az login --service-principal -u $AZURE_SP_CLIENT_ID -p $AZURE_SP_CLIENT_SECRET --tenant $AZURE_TENANT_ID)
echo $account

echo "Setup terraform."
export TF_VAR_azure_tenant_id=$AZURE_TENANT_ID 
export TF_VAR_azure_subscription_id=$(echo $account | jq -r .[].id)
export TF_VAR_azure_sp_client_id=$AZURE_SP_CLIENT_ID
export TF_VAR_azure_sp_client_secret=$AZURE_SP_CLIENT_SECRET

pushd terraform
terraform init
echo "RESOURCE_GROUP=$(terraform output --raw resource_group_name)" >> $GITHUB_ENV
echo "VIEW_CLUSTER_NAME=$(terraform output --raw view_cluster_name)" >> $GITHUB_ENV
echo "BUILD_CLUSTER_NAME=$(terraform output --raw build_cluster_name)" >> $GITHUB_ENV
echo "RUN_CLUSTER_NAME=$(terraform output --raw run_cluster_name)" >> $GITHUB_ENV
echo "ITERATE_CLUSTER_NAME=$(terraform output --raw iterate_cluster_name)" >> $GITHUB_ENV

export RESOURCE_GROUP=$(terraform output --raw resource_group_name)
export VIEW_CLUSTER_NAME=$(terraform output --raw view_cluster_name)
export BUILD_CLUSTER_NAME=$(terraform output --raw build_cluster_name)
export RUN_CLUSTER_NAME=$(terraform output --raw run_cluster_name)
export ITERATE_CLUSTER_NAME=$(terraform output --raw iterate_cluster_name)
popd

echo "Setup letsencrypt variables."
export AZURE_CERT_MANAGER_SP_PASSWORD=$(az keyvault secret show -n sp-tap-cert-manager --vault-name kv-tanzu | jq -r .value | base64 -w0)
export CERTIFICATE_EMAIL_ADDRESS=$(az keyvault secret show -n letsencrypt-email-address --vault-name kv-tanzu | jq -r .value)
export AZURE_SUBSCRIPTION_ID=$(az account show | jq -r .id)
export AZURE_CERT_MANAGER_SP_CLIENT_ID=$(az keyvault secret show -n sp-tap-cert-manager-id --vault-name kv-tanzu | jq -r .value)
export AZURE_TENANT_ID=$(az account show | jq -r .tenantId)
export AZURE_DNS_ZONE_RESOURCE_GROUP=rg-tmc
export AZURE_DNS_ZONE=ullom.xyz

pushd tls

for cluster_name in $VIEW_CLUSTER_NAME $BUILD_CLUSTER_NAME $RUN_CLUSTER_NAME $ITERATE_CLUSTER_NAME; do
    echo "Getting cluster credentials: $cluster_name."
    az aks get-credentials -n $cluster_name -g $RESOURCE_GROUP -a --overwrite

    echo "Deploying letsencrypt ClusterIssuer."
    envsubst < letsencrypt-prod.yaml > letsencrypt-prod-final.yaml
    kubectl apply -f letsencrypt-prod-final.yaml
done

kubectl config use-context $VIEW_CLUSTER_NAME-admin
kubectl apply -f tap-gui.tap2.ullom.xyz.yaml

popd
