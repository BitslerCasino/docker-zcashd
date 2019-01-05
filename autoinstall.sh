#!/usr/bin/env bash

set -e

if [[ $EUID -ne 0 ]]; then
   echo "This script must be ran as root or sudo" 1>&2
   exit 1
fi

echo "Installing ZCash Docker"

mkdir -p $HOME/.zecdocker

echo "Initial ZCash Configuration"

read -p 'rpcuser: ' rpcuser
read -p 'rpcpassword: ' rpcpassword

echo "Creating ZCash configuration at $HOME/.zecdocker/zcash.conf"

cat >$HOME/.zecdocker/zcash.conf <<EOL
server=1
listen=1
rpcuser=$rpcuser
rpcpassword=$rpcpassword
rpcport=8232
rpcthreads=4
dbcache=8000
par=0
port=8233
rpcallowip=127.0.0.1
rpcallowip=$(curl -s https://canihazip.com/s)
addnode=mainnet.z.cash
printtoconsole=1
EOL

echo Installing ZCash Container

docker volume create --name=zec-data
docker run -v zec-data:/zcash --name=zec-node -d \
      -p 8232:8232 \
      -p 8233:8233 \
      -v $HOME/.zecdocker/zcash.conf:/zcash/.zcash/zcash.conf \
      bitsler/docker-zcashd:latest

echo "Creating shell script"

cat >/usr/bin/zec-cli <<'EOL'
#!/usr/bin/env bash
docker exec -it zec-node /bin/bash -c "zcash-cli $*"
EOL

cat >/usr/bin/zec-update <<'EOL'
#!/usr/bin/env bash
if [[ $EUID -ne 0 ]]; then
   echo "This script must be ran as root or sudo" 1>&2
   exit 1
fi
echo "Updating zec..."
sudo docker stop zec-node
sudo docker rm zec-node
sudo docker pull bitsler/docker-zcashd:latest
docker run -v zec-data:/zcashd --name=zec-node -d \
      -p 8232:8232 \
      -p 8233:8233 \
      -v $HOME/.zecdocker/zcash.conf:/zcashd/.zcash/zcash.conf \
      bitsler/docker-zcashd:latest
EOL

cat >/usr/bin/zec-rm <<'EOL'
#!/usr/bin/env bash
if [[ $EUID -ne 0 ]]; then
   echo "This script must be ran as root or sudo" 1>&2
   exit 1
fi
echo "WARNING! This will delete ALL zec-docker installation and files"
echo "Make sure your wallet.dat is safely backed up, there is no way to recover it!"
function uninstall() {
  sudo docker stop zec-node
  sudo docker rm zec-node
  sudo rm -rf ~/docker/volumes/zec-data ~/.zecdocker /usr/bin/zec-cli
  sudo docker volume rm zec-data
  echo "Successfully removed"
  sudo rm -- "$0"
}
read -p "Continue (Y)?" choice
case "$choice" in
  y|Y ) uninstall;;
  * ) exit;;
esac
EOL

chmod +x /usr/bin/zec-cli
chmod +x /usr/bin/zec-rm
chmod +x /usr/bin/zec-update

echo
echo "==========================="
echo "==========================="
echo "Installation Complete"
echo "You can now run normal zec-cli commands"
echo "Your configuration file is at $HOME/.zecdocker/zcash.conf"
echo "If you wish to change it, make sure to restart zec-node"
echo "IMPORTANT: To stop zec-node gracefully, use 'zec-cli stop' and wait for the container to stop to avoid corruption"