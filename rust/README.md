## Prerequisites

#### Foundry

```
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

#### Just

See https://github.com/casey/just for installation instructions.

## Deploy a Contract

Update the filepath fields in `config.toml`:

```toml
keystore_path = "/tmp/testnet.keystore.json"
pw_path = "/tmp/testnet.pw"
```

Run the deploy script:

```
just deploy
```
