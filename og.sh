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
echo "export OG_CHAIN_ID=zgtendermint_9000-1" >> $HOME/.bash_profile
source $HOME/.bash_profile

# update
sudo apt update && sudo apt upgrade -y

# packages
apt install curl iptables build-essential git wget jq make gcc nano tmux htop nvme-cli pkg-config libssl-dev libleveldb-dev tar clang bsdmainutils ncdu unzip libleveldb-dev -y

# install go
if ! [ -x "$(command -v go)" ]; then
ver="1.21.3" && \
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz" && \
sudo rm -rf /usr/local/go && \
sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz" && \
rm "go$ver.linux-amd64.tar.gz" && \
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> $HOME/.bash_profile && \
source $HOME/.bash_profile
fi

# download binary
wget https://rpc-zero-gravity-testnet.trusted-point.com/evmosd
chmod +x ./evmosd
mv ./evmosd /usr/local/bin/
evmosd version

# config
evmosd config chain-id $OG_CHAIN_ID
evmosd config keyring-backend os

# init
evmosd init $NODENAME --chain-id $OG_CHAIN_ID

# download genesis and addrbook
wget https://rpc-zero-gravity-testnet.trusted-point.com/genesis.json -O $HOME/.evmosd/config/genesis.json
curl -L https://snapshot.validatorvn.com/og/addrbook.json > $HOME/.evmosd/config/addrbook.json

# set minimum gas price
sed -i -e "s|^minimum-gas-prices *=.*|minimum-gas-prices = \"0.00252aevmos\"|" $HOME/.evmosd/config/app.toml

# set peers and seeds
SEEDS="8c01665f88896bca44e8902a30e4278bed08033f@54.241.167.190:26656,b288e8b37f4b0dbd9a03e8ce926cd9c801aacf27@54.176.175.48:26656,8e20e8e88d504e67c7a3a58c2ea31d965aa2a890@54.193.250.204:26656,e50ac888b35175bfd4f999697bdeb5b7b52bfc06@54.215.187.94:26656,c9b8e7e220178817c84c7268e186b231bc943671@og-testnet-seed.itrocket.net:47656"
PEERS="c597d920f965da0d6ca37b1a3a91be7d4586d78d@78.46.71.227:56656,312d540450524b1332cdb2af1ddffed179e47601@88.99.254.62:21656,32109a1087bcd2e8c00cd975c39353e3dd799b5f@95.217.95.10:26656,9a8ac6f12e1d1be5c999ed5184cde64473a297c3@149.102.152.54:26656,6fbb5fdd7c6ef88fa89db0cb0ffe8086ee63d511@135.181.6.189:26656,ca31cf94d5878eeb74eda79d01a28e6d85e5e50d@5.104.82.110:26656,19892d9b9e7eec08c07b48b52a59c5f666bdd6fd@135.181.75.121:26656,5e3fef852150c077adfbfebfba840a01d0b0801d@37.27.59.176:17656,325c942608727d45f9cb87fb2c4b4fdd6be7e314@95.217.47.14:26656,e444f30ce4bf9783ee4748f7d9b075611336594c@84.247.156.62:26656,664d2d4f0be9fa44403eb3942e68db17581be619@178.170.39.168:61156"
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.evmosd/config/config.toml

# disable indexing
indexer="null"
sed -i -e "s/^indexer *=.*/indexer = \"$indexer\"/" $HOME/.evmosd/config/config.toml

# config pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="10"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.evmosd/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.evmosd/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.evmosd/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.evmosd/config/app.toml
sed -i "s/snapshot-interval *=.*/snapshot-interval = 0/g" $HOME/.evmosd/config/app.toml

# enable prometheus
sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.evmosd/config/config.toml

# create service
sudo tee /etc/systemd/system/ogd.service > /dev/null << EOF
[Unit]
Description=0G node service
After=network-online.target
[Service]
User=$USER
ExecStart=$(which evmosd) start
Restart=on-failure
RestartSec=10
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF

# reset
evmosd tendermint unsafe-reset-all --home $HOME/.evmosd --keep-addr-book
curl https://snapshot.validatorvn.com/og/data.tar.lz4 | lz4 -dc - | tar -xf - -C $HOME/.evmosd

# start service
sudo systemctl daemon-reload
sudo systemctl enable ogd
sudo systemctl restart ogd

break
;;

"Create Wallet")
evmosd keys add $WALLET
echo "============================================================"
echo "Save address and mnemonic"
echo "============================================================"
OG_WALLET_ADDRESS=$(evmosd keys show $WALLET -a)
OG_VALOPER_ADDRESS=$(evmosd keys show $WALLET --bech val -a)
echo 'export OG_WALLET_ADDRESS='${OG_WALLET_ADDRESS} >> $HOME/.bash_profile
echo 'export OG_VALOPER_ADDRESS='${OG_VALOPER_ADDRESS} >> $HOME/.bash_profile
source $HOME/.bash_profile

break
;;

"Create Validator")
evmosd tx staking create-validator \
--amount=1000000aevmos \
--pubkey=$(evmosd tendermint show-validator) \
--moniker=$NODENAME \
--chain-id=zgtendermint_9000-1 \
--commission-rate=0.10 \
--commission-max-rate=0.20 \
--commission-max-change-rate=0.01 \
--min-self-delegation=1 \
--from=wallet \
--gas-prices=250000000aevmos \
--gas-adjustment=1.5 \
--gas=300000 \
-y 
  
break
;;

"Exit")
exit
;;
*) echo "invalid option $REPLY";;
esac
done
done
