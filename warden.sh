#!/bin/bash

while true
do

# Logo

echo -e '\e[40m\e[91m'
echo -e '  ____                  _                    '
echo -e ' / ___|_ __ _   _ _ __ | |_ ___  _ __        '
echo -e '| |   |  __| | | |  _ \| __/ _ \|  _ \       '
echo -e '| |___| |  | |_| | |_) | || (_) | | | |      '
echo -e ' \____|_|   \__  |  __/ \__\___/|_| |_|      '
echo -e '            |___/|_|                         '
echo -e '\e[0m'

sleep 2

# Menu

PS3='Select an action: '
options=(
"Install"
"Create Wallet"
"Create Validator"
"Exit")
select opt in "${options[@]}"
do
case $opt in

"Install")
echo "============================================================"
echo "Install start"
echo "============================================================"

# set vars
if [ ! $NODENAME ]; then
	read -p "Enter node name: " NODENAME
	echo 'export NODENAME='$NODENAME >> $HOME/.bash_profile
fi
if [ ! $WALLET ]; then
	echo "export WALLET=wallet" >> $HOME/.bash_profile
fi
echo "export WARDEN_CHAIN_ID=buenavista-1" >> $HOME/.bash_profile
source $HOME/.bash_profile

# update
sudo apt update && sudo apt upgrade -y

# packages
apt install curl iptables build-essential git wget jq make gcc nano tmux htop nvme-cli pkg-config libssl-dev libleveldb-dev tar clang bsdmainutils ncdu unzip libleveldb-dev -y

# install go
sudo rm -rf /usr/local/go
curl -L https://go.dev/dl/go1.21.6.linux-amd64.tar.gz | sudo tar -xzf - -C /usr/local
echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> $HOME/.bash_profile
source .bash_profile

# download binary
cd && wget https://github.com/warden-protocol/wardenprotocol/releases/download/v0.3.2/wardend_Linux_x86_64.zip
unzip wardend_Linux_x86_64.zip
rm -rf wardend_Linux_x86_64.zip
chmod +x wardend
sudo mv wardend $(which wardend)

# config
#wardend config chain-id $WARDEN_CHAIN_ID
#wardend config keyring-backend test

# init
wardend init $NODENAME --chain-id $WARDEN_CHAIN_ID

# download genesis and addrbook
curl -L https://snapshots-testnet.nodejumper.io/wardenprotocol-testnet/genesis.json > $HOME/.warden/config/genesis.json
curl -L https://snapshots-testnet.nodejumper.io/wardenprotocol-testnet/addrbook.json > $HOME/.warden/config/addrbook.json

# set minimum gas price
sed -i -e 's|^minimum-gas-prices *=.*|minimum-gas-prices = "0.01uward"|' $HOME/.warden/config/app.toml

# set peers and seeds
SEEDS="ddb4d92ab6eba8363bab2f3a0d7fa7a970ae437f@sentry-1.buenavista.wardenprotocol.org:26656,c717995fd56dcf0056ed835e489788af4ffd8fe8@sentry-2.buenavista.wardenprotocol.org:26656,e1c61de5d437f35a715ac94b88ec62c482edc166@sentry-3.buenavista.wardenprotocol.org:26656"
PEERS="be9d2a009589d3d7194ad66a3baf66fc47a87033@144.76.97.251:26726,06cfa1a284c4569aa0b2d691d66772e7aa47c1ce@84.247.152.165:11256,deb547e952e0d8e988b7cf5a63a19ff09562e49c@161.97.129.54:26656,5893aa84f2262c95699bc23b1fc027bc8138d093@65.108.68.214:18656,c3717a2912fdd80b727c6ce29d80c0b1aabcfed4@65.21.10.115:27356,89228ac045451424da90f16b2b85b8e16f032cf6@84.201.158.9:26656,d3e0330d10424fc9dbba8992910490180c55459f@178.170.39.168:61056,ad4ff9fc6c6d86a47c6ef4cf247df47cffbf5ca3@95.111.249.54:11256,c6b0ef8d39a28c2c0f256d7b873b652c89c8c7c4@207.180.196.249:26656,2f6e9f21c33cdba23934c9b08cb32c8fc9a23ef6@213.199.35.46:11256,b209b221edc3c8a61c50ad895f6852b08cf718f5@173.212.232.122:26656,f5c40ec1bd25add3894ccccb768d2fa37cf09ae1@65.108.211.205:26656,f3f7f286f08e4e5d1c1a221831f74a46d2b20af4@46.250.238.52:26656,ae723baecf4999d436d6a14fd1f920761872ac86@195.3.222.189:36656,482389d550a5820f3b1ad44266ce762d5492164e@193.46.243.89:11256,c75d542cedb29fb22d4a68203798103988213b09@213.246.45.16:56656"
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.warden/config/config.toml

# disable indexing
indexer="null"
sed -i -e "s/^indexer *=.*/indexer = \"$indexer\"/" $HOME/.warden/config/config.toml

#update
sed -i '1i\\
$ a\
[oracle]\
enabled = "true"\
oracle_address = "localhost:8080"\
client_timeout = "2s"\
metrics_enabled = "true"' $HOME/.warden/config/app.toml

# config pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="10"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.warden/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.warden/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.warden/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.warden/config/app.toml
sed -i "s/snapshot-interval *=.*/snapshot-interval = 0/g" $HOME/.warden/config/app.toml

#update
sed -i \
  -e 's/timeout_precommit_delta = ".*"/timeout_precommit_delta = "0ms"/g' \
  $HOME/.warden/config/config.toml

# enable prometheus
sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.warden/config/config.toml

#update
cd && curl -Ls https://github.com/skip-mev/slinky/releases/download/v1.0.4/slinky-1.0.4-linux-amd64.tar.gz > slinky-1.0.4-linux-amd64.tar.gz
tar -xzf slinky-1.0.4-linux-amd64.tar.gz
sudo mv slinky-1.0.4-linux-amd64/slinky $HOME/go/bin/slinky

#update
GRPC_PORT=$(grep 'address = ' "$HOME/.warden/config/app.toml" | awk -F: '{print $NF}' | grep '90"$' | tr -d '"')

#update
sudo tee /etc/systemd/system/warden-slinky.service > /dev/null << EOF
[Unit]
Description=Slinky for Warden Protocol service
After=network-online.target
[Service]
User=$USER
ExecStart=$(which slinky) --market-map-endpoint="127.0.0.1:$GRPC_PORT" --log-disable-file-rotation
Restart=on-failure
RestartSec=10
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable warden-slinky
sudo systemctl start warden-slinky

# create service
sudo tee /etc/systemd/system/wardend.service > /dev/null << EOF
[Unit]
Description=Warden Protocol node service
After=network-online.target
[Service]
User=$USER
ExecStart=$(which wardend) start
Restart=on-failure
RestartSec=10
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF

# reset
wardend tendermint unsafe-reset-all --home $HOME/.warden --keep-addr-book
curl https://snapshots-testnet.nodejumper.io/wardenprotocol-testnet/wardenprotocol-testnet_latest.tar.lz4 | lz4 -dc - | tar -xf - -C $HOME/.warden

# start service
sudo systemctl daemon-reload
sudo systemctl enable wardend
sudo systemctl restart wardend
sudo systemctl restart warden-slinky

break
;;

"Create Wallet")
wardend keys add $WALLET
echo "============================================================"
echo "Save address and mnemonic"
echo "============================================================"
WARDEN_WALLET_ADDRESS=$(wardend keys show $WALLET -a)
WARDEN_VALOPER_ADDRESS=$(wardend keys show $WALLET --bech val -a)
echo 'export WARDEN_WALLET_ADDRESS='${WARDEN_WALLET_ADDRESS} >> $HOME/.bash_profile
echo 'export WARDEN_VALOPER_ADDRESS='${WARDEN_VALOPER_ADDRESS} >> $HOME/.bash_profile
source $HOME/.bash_profile

break
;;

"Create Validator")
wardend tx staking create-validator $HOME/.warden/validator.json \
    --from=wallet \
    --chain-id=buenavista-1 \
    --fees=500uward -y 
  
break
;;

"Exit")
exit
;;
*) echo "invalid option $REPLY";;
esac
done
done
