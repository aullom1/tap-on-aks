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

echo "Setup auth0 variables."
export AUTH0_CLIENT_ID=$(az keyvault secret show -n auth0-client-id --vault-name kv-tanzu | jq -r .value | base64 -w0)
export AUTH0_CLIENT_SECRET=$(az keyvault secret show -n auth0-client-secret --vault-name kv-tanzu | jq -r .value | base64 -w0)

pushd auth

echo "Install pinniped-concierge on each cluster"
for cluster_name in $VIEW_CLUSTER_NAME $BUILD_CLUSTER_NAME $RUN_CLUSTER_NAME $ITERATE_CLUSTER_NAME; do
    echo "Getting cluster credentials: $cluster_name."
    az aks get-credentials -n $cluster_name -g $RESOURCE_GROUP -a --overwrite

    echo "Deploying pinniped-concierge."
    kapp deploy -y --app pinniped-concierge \
        -f https://get.pinniped.dev/v0.12.0/install-pinniped-concierge-crds.yaml \
        -f https://get.pinniped.dev/v0.12.0/install-pinniped-concierge.yaml
    kapp deploy -y --app pinniped-concierge-jwt --into-ns pinniped-concierge -f pinniped-concierge/jwt_authenticator.yaml
done

popd
