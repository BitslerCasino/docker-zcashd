#!/usr/bin/env bash

set -e

if [[ $EUID -ne 0 ]]; then
   echo "This script must be ran as root or sudo" 1>&2
   exit 1
fi

echo "Creating shell script"

cat >/usr/bin/zec-cli <<'EOL'
#!/usr/bin/env bash
docker exec -it zec-node /bin/bash -c "zcash-cli $*"
EOL

cat >/usr/bin/zec-update <<'EOL'
#!/usr/bin/env bash
set -e
if [[ $EUID -ne 0 ]]; then
   echo "This script must be ran as root or sudo" 1>&2
   exit 1
fi
VERSION="${1:-latest}"
echo "Stopping zcash"
sudo docker stop zec-node
echo "Waiting zec gracefull shutdown..."
docker wait zec-node
echo "Updating zec to $VERSION version..."
docker pull bitsler/docker-zcashd:$VERSION
echo "Removing old zec installation"
docker rm zec-node
echo "Running new zec-node container"
docker run -v zec-data:/zcashd --name=zec-node -d \
      -p 8232:8232 \
      -p 8233:8233 \
      -v $HOME/.zecdocker/zcash.conf:/zcashd/.zcash/zcash.conf \
      bitsler/docker-zcashd:$VERSION

echo "Zcash successfully updated to $VERSION and started"
echo ""
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

echo "DONE!"