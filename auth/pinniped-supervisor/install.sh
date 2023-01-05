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

export RESOURCE_GROUP=$(terraform output --raw resource_group_name)
export VIEW_CLUSTER_NAME=$(terraform output --raw view_cluster_name)
popd

echo "Setup auth0 variables."
export AUTH0_CLIENT_ID=$(az keyvault secret show -n auth0-client-id --vault-name kv-tanzu | jq -r .value)
export AUTH0_CLIENT_SECRET=$(az keyvault secret show -n auth0-client-secret --vault-name kv-tanzu | jq -r .value)

pushd auth

echo "Install pinniped-supervisor on view cluster"
az aks get-credentials -n $VIEW_CLUSTER_NAME -g $RESOURCE_GROUP -a --overwrite
envsubst < pinniped-supervisor/oidc_identity_provider.yaml > pinniped-supervisor/oidc_identity_provider.yaml
kapp deploy -y --app pinniped-supervisor --into-ns pinniped-supervisor -f pinniped-supervisor -f https://get.pinniped.dev/v0.12.0/install-pinniped-supervisor.yaml

popd
