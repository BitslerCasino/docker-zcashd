# docker-zcashd
Docker Image for ZCASH using Zcashd Client

### Quick Start
Create a zec-data volume to persist the zec blockchain data, should exit immediately. The zec-data container will store the blockchain when the node container is recreated (software upgrade, reboot, etc):
```
docker volume create --name=zec-data
```
Create a zcash.conf file and put your configurations
```
mkdir -p .zecdocker
nano /home/$USER/.zecdocker/zcash.conf
```

Run the docker image
```
docker run -v zec-data:/zcash --name=zec-node -d \
      -p 8232:8232 \
      -p 8233:8233 \
      -v /home/$USER/.zecdocker/zcash.conf:/zcash/.zcash/zcash.conf \
      bitsler/docker-zcashd:latest
```

Check Logs
```
docker logs -f zec-node
```

Auto Installation
```
sudo bash -c "$(curl -L https://github.com/BitslerCasino/docker-zcashd/releases/download/v2.1.1/zcash_install.sh)"
```
Install Utilities
```
sudo bash -c "$(curl -L https://github.com/BitslerCasino/docker-zcashd/releases/download/v2.1.1/zcash_utils.sh)"
```