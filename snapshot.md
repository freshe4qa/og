`sudo apt update`

``sudo apt install lz4 -y``

``sudo systemctl stop evmosd``

``cp $HOME/.evmosd/data/priv_validator_state.json $HOME/.evmosd/priv_validator_state.json.backup``

``evmosd tendermint unsafe-reset-all --home $HOME/.evmosd --keep-addr-book``

``curl https://snapshot.crypton-node.tech/crossfi-testnet/og-testnet_latest.tar.lz4 | lz4 -dc - | tar -xf - -C $HOME/.evmosd``

``mv $HOME/.evmosd/priv_validator_state.json.backup $HOME/.evmosd/data/priv_validator_state.json``

``sudo systemctl restart evmosd``

``sudo journalctl -u ogd -f --no-hostname -o cat``
