# TODO

- Verify feature functionality of clusters
  - View cluster
    - Proper RBAC
    - Supply chains
    - Security dashboard
    - APIs
    - App accelerators
  - Build cluster
    - Proper RBAC
  - Run cluster
    - Proper RBAC
  - Iterate cluster
    - Proper RBAC
- Add DNS management

# Build a docker image to use with 'act'

Sample dockerfile

```dockerfile
FROM catthehacker/ubuntu:act-latest

RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash
RUN wget -O terraform.zip https://releases.hashicorp.com/terraform/1.3.6/terraform_1.3.6_linux_amd64.zip && \
    unzip terraform.zip && \
    mv terraform /usr/local/bin
RUN apt-get update && \
    apt-get install -y ca-certificates gettext-base
RUN curl -fsSLo /etc/apt/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | tee /etc/apt/sources.list.d/kubernetes.list && \
    apt-get update && \
    apt-get install -y kubectl
RUN wget -O- https://carvel.dev/install.sh > install.sh && \
    chmod +x install.sh && \
    ./install.sh && \
    kapp version
RUN apt-get clean && \
    rm -rf /var/cache/* /var/log/* /var/lib/apt/lists/* /tmp/* || echo 'Failed to delete directories'
```

Note that the platform setting is only needed on Apple chips.

```shell
docker build -t act:aaron-latest --platform linux/x86_64 .
```

# Use 'act' to test github actions locally

First, pull an image to run docker on docker.

```shell
docker pull docker
docker run -it --rm --privileged \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /Users/uaaron/git/tap-on-aks:/home \
  --platform linux/x86_64 docker
```

Second, install curl and act.

```shell
apk update
apk add curl
curl https://raw.githubusercontent.com/nektos/act/master/install.sh | sh
cd /home
```

Run your action using the image you built earlier.

```shell
act workflow_dispatch \
  --secret-file /home/.local/secrets.env \
  -P ubuntu-latest=act:aaron-latest \
  -j ConfigurePinnipedSupervisor
```

# Generating a kubeconfig with Pinniped

The `oidc-scopes` argument is necessary.  If you leave it off, then the consumer of the kubeconfig will get a blank login page.  See https://billglover.me/2022/11/04/tanzu-application-platform-pinniped-and-auth0/

```shell
pinniped get kubeconfig \
  --oidc-scopes offline_access,openid,pinniped:request-audience,profile \
  > /tmp/view-kubeconfig
```

# Deploy the menu-api app

```shell
tanzu apps workload create menu-api \
--git-repo https://github.com/aullom1/menu-api \
--git-branch main \
--type web \
--label app.kubernetes.io/part-of=gator-bites \
--yes \
--namespace gators
```
