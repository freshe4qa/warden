<p align="center">
  <img height="100" height="auto" src="https://github.com/freshe4qa/warden/assets/85982863/b4fe1f49-86de-4fe0-b6a2-3f938286b4ab">
</p>

# Warden Testnet — buenavista-1

Official documentation:
>- [Validator setup instructions](https://docs.wardenprotocol.org)

Explorer:
>- [Explorer](https://testnet.warden.explorers.guru)

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
wget https://raw.githubusercontent.com/freshe4qa/warden/main/warden.sh && chmod +x warden.sh && ./warden.sh
```

## Post installation

When installation is finished please load variables into system
```
source $HOME/.bash_profile
```

Synchronization status:
```
wardend status 2>&1 | jq .SyncInfo
```

### Create wallet
To create new wallet you can use command below. Don’t forget to save the mnemonic
```
wardend keys add $WALLET
```

Recover your wallet using seed phrase
```
wardend keys add $WALLET --recover
```

To get current list of wallets
```
wardend keys list
```

## Usefull commands
### Service management
Check logs
```
journalctl -fu wardend -o cat
```

Start service
```
sudo systemctl start wardend
```

Stop service
```
sudo systemctl stop wardend
```

Restart service
```
sudo systemctl restart wardend
```

### Node info
Synchronization info
```
wardend status 2>&1 | jq .SyncInfo
```

Validator info
```
wardend status 2>&1 | jq .ValidatorInfo
```

Node info
```
wardend status 2>&1 | jq .NodeInfo
```

Show node id
```
wardend tendermint show-node-id
```

### Wallet operations
List of wallets
```
wardend keys list
```

Recover wallet
```
wardend keys add $WALLET --recover
```

Delete wallet
```
wardend keys delete $WALLET
```

Get wallet balance
```
wardend query bank balances $WARDEN_WALLET_ADDRESS
```

Transfer funds
```
wardend tx bank send $WARDEN_WALLET_ADDRESS <TO_WARDEN_WALLET_ADDRESS> 10000000uward
```

### Voting
```
wardend tx gov vote 1 yes --from $WALLET --chain-id=$WARDEN_CHAIN_ID
```

### Staking, Delegation and Rewards
Delegate stake
```
wardend tx staking delegate $WARDEN_VALOPER_ADDRESS 10000000uward --from=$WALLET --chain-id=$WARDEN_CHAIN_ID --gas=auto
```

Redelegate stake from validator to another validator
```
wardend tx staking redelegate <srcValidatorAddress> <destValidatorAddress> 10000000uward --from=$WALLET --chain-id=$WARDEN_CHAIN_ID --gas=auto
```

Withdraw all rewards
```
wardend tx distribution withdraw-all-rewards --from=$WALLET --chain-id=$WARDEN_CHAIN_ID --gas=auto
```

Withdraw rewards with commision
```
wardend tx distribution withdraw-rewards $WARDEN_VALOPER_ADDRESS --from=$WALLET --commission --chain-id=$WARDEN_CHAIN_ID
```

Unjail validator
```
wardend tx slashing unjail \
  --broadcast-mode=block \
  --from=$WALLET \
  --chain-id=$WARDEN_CHAIN_ID \
  --gas=auto
```
