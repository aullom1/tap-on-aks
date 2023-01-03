install_script=$(mktemp)
wget -O- https://carvel.dev/install.sh > $install_script
bash $install_script
kapp version
