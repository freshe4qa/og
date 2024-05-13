<p align="center">
  <img height="100" height="auto" src="https://github.com/freshe4qa/og/assets/85982863/64481bdc-a74e-4f04-b07a-e99a72eb3861">
</p>

# Og Testnet — zgtendermint_16600-1

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

## Set up your artela fullnode
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
evmosd status 2>&1 | jq .SyncInfo
```

### Create wallet
To create new wallet you can use command below. Don’t forget to save the mnemonic
```
evmosd keys add $WALLET
```

Recover your wallet using seed phrase
```
evmosd keys add $WALLET --recover
```

To get current list of wallets
```
evmosd keys list
```

## Usefull commands
### Service management
Check logs
```
journalctl -fu evmosd -o cat
```

Start service
```
sudo systemctl start evmosd
```

Stop service
```
sudo systemctl stop evmosd
```

Restart service
```
sudo systemctl restart evmosd
```

### Node info
Synchronization info
```
evmosd status 2>&1 | jq .SyncInfo
```

Validator info
```
evmosd status 2>&1 | jq .ValidatorInfo
```

Node info
```
evmosd status 2>&1 | jq .NodeInfo
```

Show node id
```
evmosd tendermint show-node-id
```

### Wallet operations
List of wallets
```
evmosd keys list
```

Recover wallet
```
evmosd keys add $WALLET --recover
```

Delete wallet
```
evmosd keys delete $WALLET
```

Get wallet balance
```
evmosd query bank balances $OG_WALLET_ADDRESS
```

Transfer funds
```
evmosd tx bank send $OG_WALLET_ADDRESS <TO_OG_WALLET_ADDRESS> 10000000aevmos
```

### Voting
```
evmosd tx gov vote 1 yes --from $WALLET --chain-id=$OG_CHAIN_ID
```

### Staking, Delegation and Rewards
Delegate stake
```
evmosd tx staking delegate $OG_VALOPER_ADDRESS 10000000aevmos --from=$WALLET --chain-id=$OG_CHAIN_ID --gas=auto
```

Redelegate stake from validator to another validator
```
evmosd tx staking redelegate <srcValidatorAddress> <destValidatorAddress> 10000000aevmos --from=$WALLET --chain-id=$OG_CHAIN_ID --gas=auto
```

Withdraw all rewards
```
evmosd tx distribution withdraw-all-rewards --from=$WALLET --chain-id=$OG_CHAIN_ID --gas=auto
```

Withdraw rewards with commision
```
evmosd tx distribution withdraw-rewards $OG_VALOPER_ADDRESS --from=$WALLET --commission --chain-id=$evmos_CHAIN_ID
```

Unjail validator
```
evmosd tx slashing unjail \
  --broadcast-mode=block \
  --from=$WALLET \
  --chain-id=$OG_CHAIN_ID \
  --gas=auto
```
