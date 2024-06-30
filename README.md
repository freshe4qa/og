<p align="center">
  <img height="100" height="auto" src="https://github.com/freshe4qa/og/assets/85982863/64481bdc-a74e-4f04-b07a-e99a72eb3861">
</p>

# Og Testnet — zgtendermint_16600-2

Official documentation:
>- [Validator setup instructions](https://docs.0g.ai/0g-doc)

Explorer:
>- [Exolorer](https://testnet.0g.explorers.guru)

### Minimum Hardware Requirements
 - 4x CPUs; the faster clock speed the better
 - 8GB RAM
 - 100GB of storage (SSD or NVME)

### Recommended Hardware Requirements 
 - 8x CPUs; the faster clock speed the better
 - 16GB RAM
 - 1TB of storage (SSD or NVME)

## Set up your og fullnode
```
wget https://raw.githubusercontent.com/freshe4qa/artela/main/og.sh && chmod +x og.sh && ./og.sh
```

## Post installation

When installation is finished please load variables into system
```
source $HOME/.bash_profile
```

Synchronization status:
```
0gchaind status 2>&1 | jq .SyncInfo
```

### Create wallet
To create new wallet you can use command below. Don’t forget to save the mnemonic
```
0gchaind keys add $WALLET
```

Recover your wallet using seed phrase
```
0gchaind keys add $WALLET --recover
```

To get current list of wallets
```
0gchaind keys list
```

## Usefull commands
### Service management
Check logs
```
journalctl -fu 0gchaind -o cat
```

Start service
```
sudo systemctl start 0gchaind
```

Stop service
```
sudo systemctl stop 0gchaind
```

Restart service
```
sudo systemctl restart 0gchaind
```

### Node info
Synchronization info
```
0gchaind status 2>&1 | jq .SyncInfo
```

Validator info
```
0gchaind status 2>&1 | jq .ValidatorInfo
```

Node info
```
0gchaind status 2>&1 | jq .NodeInfo
```

Show node id
```
0gchaind tendermint show-node-id
```

### Wallet operations
List of wallets
```
0gchaind keys list
```

Recover wallet
```
0gchaind keys add $WALLET --recover
```

Delete wallet
```
0gchaind keys delete $WALLET
```

Get wallet balance
```
0gchaind query bank balances $OG_WALLET_ADDRESS
```

Transfer funds
```
0gchaind tx bank send $OG_WALLET_ADDRESS <TO_OG_WALLET_ADDRESS> 10000000ua0gi
```

### Voting
```
0gchaind tx gov vote 1 yes --from $WALLET --chain-id=$OG_CHAIN_ID
```

### Staking, Delegation and Rewards
Delegate stake
```
0gchaind tx staking delegate $OG_VALOPER_ADDRESS 10000000ua0gi --from=$WALLET --chain-id=$OG_CHAIN_ID --gas=auto
```

Redelegate stake from validator to another validator
```
0gchaind tx staking redelegate <srcValidatorAddress> <destValidatorAddress> 10000000ua0gi --from=$WALLET --chain-id=$OG_CHAIN_ID --gas=auto
```

Withdraw all rewards
```
0gchaind tx distribution withdraw-all-rewards --from=$WALLET --chain-id=$OG_CHAIN_ID --gas=auto
```

Withdraw rewards with commision
```
0gchaind tx distribution withdraw-rewards $OG_VALOPER_ADDRESS --from=$WALLET --commission --chain-id=$evmos_CHAIN_ID
```

Unjail validator
```
0gchaind tx slashing unjail \
  --broadcast-mode=block \
  --from=$WALLET \
  --chain-id=$OG_CHAIN_ID \
  --gas=auto
```
