# Manual node setup
If you want to setup fullnode manually follow the steps below

## Setting up vars
Here you have to put name of your moniker (validator) that will be visible in explorer
```
NODENAME=<YOUR_MONIKER_NAME>
```

Save and import variables into system
```
echo "export NODENAME=$NODENAME" >> $HOME/.bash_profile
if [ ! $WALLET ]; then
	echo "export WALLET=wallet" >> $HOME/.bash_profile
fi
echo "export OG_CHAIN_ID=zgtendermint_16600-1" >> $HOME/.bash_profile
source $HOME/.bash_profile
```

## Update packages
```
sudo apt update && sudo apt upgrade -y
```

## Install dependencies
```
apt install curl iptables build-essential git wget jq make gcc nano tmux htop nvme-cli pkg-config libssl-dev libleveldb-dev tar clang bsdmainutils ncdu unzip libleveldb-dev -y
```

## Install go
```
if ! [ -x "$(command -v go)" ]; then
ver="1.20.3" && \
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz" && \
sudo rm -rf /usr/local/go && \
sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz" && \
rm "go$ver.linux-amd64.tar.gz" && \
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> $HOME/.bash_profile && \
source $HOME/.bash_profile && \
go version
fi
```

## Download and build binaries
```
cd && rm -rf 0g-chain
git clone https://github.com/0glabs/0g-chain
cd 0g-chain
git checkout v0.1.0
make install
```

## Config app
```
0gchaind config chain-id zgtendermint_16600-1
0gchaind config keyring-backend test
```

## Init app
```
0gchaind init $NODENAME --chain-id $OG_CHAIN_ID
```

## Download genesis and addrbook
```
curl -L https://snapshots-testnet.nodejumper.io/0g-testnet/genesis.json > $HOME/.0gchain/config/genesis.json
curl -L https://snapshots-testnet.nodejumper.io/0g-testnet/addrbook.json > $HOME/.0gchain/config/addrbook.json
```

## Set seeds and peers
```
SEEDS="c4d619f6088cb0b24b4ab43a0510bf9251ab5d7f@54.241.167.190:26656,44d11d4ba92a01b520923f51632d2450984d5886@54.176.175.48:26656,f2693dd86766b5bf8fd6ab87e2e970d564d20aff@54.193.250.204:26656"
PEERS="ae1c39dcf8d8a7c956a0333ca3d9176d1df87f64@62.169.23.106:26656,38154d89b8dc8496e20a0ef999e096ed03cae774@65.21.141.117:43656,6ebfc7a8a4a02f9f92b34d0b91d0a4ef7ea5f264@212.220.110.72:26656,10f385223670cf310fc55f26313cfbc3512f7cea@109.199.111.166:26656,4ec40975cbe2ec406e61b474a08613b47c7fc749@65.21.239.60:28656,da1f4985ce3df05fd085460485adefa93592a54c@172.232.33.25:26656,89189bb79a36e051abacce5f2bc1a0e6382a5a5b@185.193.67.160:26656,a25dadd5cb8feb5ad88ea39ededce5e81f90c87b@5.75.253.119:26656,5571c7e75cf4e2d48fc36ad74c8d04bed57c7312@46.250.237.246:16656,feb0cc40a3009a16a62bb843c000974565107c4c@128.140.65.68:26656,b2dcd3248fc4104b37568d98495466b4a2074672@65.109.145.247:1020,5d5620b264c6fe7b09201194ce4eea8e0f8dca8c@109.199.109.113:16656,a7db2f424dfa76abf4cab50bb99e8331541dd021@173.212.216.66:26656,3cdd680c2ffef1183495a8a6e966acf7dceabba9@62.169.21.22:16656,9fcee79a3e60ab43802c755ab160379446ee686b@109.199.106.155:16656,532f9a1c04350575e3a43dbc735600f77f35c78b@45.83.122.218:26656,59fe20be127ea2431fcf004af16f101a62269b93@38.242.144.121:26656,344ba4690fe303aadc828d31328d0a8b3a127c98@207.180.236.138:16656,aaa404ffeec36070d7f3b8c3a7f821a1750571b8@195.26.242.185:26656,90fb16e5360d64ac2332009cfc7b2eb6e8df64e7@212.162.153.183:26656"
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.0gchain/config/config.toml
```

## Config pruning
```
# disable indexing
indexer="null"
sed -i -e "s/^indexer *=.*/indexer = \"$indexer\"/" $HOME/.0gchain/config/config.toml

# config pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="10"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.0gchain/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.0gchain/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.0gchain/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.0gchain/config/app.toml
sed -i "s/snapshot-interval *=.*/snapshot-interval = 0/g" $HOME/.0gchain/config/app.toml
```

## Set minimum gas price and timeout commit
```
sed -i -e "s|^minimum-gas-prices *=.*|minimum-gas-prices = \"0.0025ua0gi\"|" $HOME/.0gchain/config/app.toml
```

## Enable prometheus
```
sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.0gchain/config/config.toml
```

## Reset chain data
```
0gchaind tendermint unsafe-reset-all
```

## Create service
```
sudo tee /etc/systemd/system/0gchaind.service > /dev/null << EOF
[Unit]
Description=0G node service
After=network-online.target
[Service]
User=$USER
ExecStart=$(which 0gchaind) start
Restart=on-failure
RestartSec=10
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF
```

## Register and start service
```
sudo systemctl daemon-reload
sudo systemctl enable 0gchaind
sudo systemctl restart 0gchaind && sudo journalctl -u 0gchaind -f -o cat
```
