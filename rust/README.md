## Prerequisites

#### Foundry

```
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

#### Just

See https://github.com/casey/just for installation instructions.

## Setup Keystore

The binaries require access to a keystore file.

If you have a private key, you can generate a keystore with a password:

```
export PRIVATE_KEY=... PASSWORD=...
just keystore
unset PRIVATE_KEY PASSWORD
```

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

This will print out a contract address:

```
2025-01-19T19:32:36.576574Z  INFO new_contract: Deployed to: 0x03C2865B77AbDC566f85DfDF02C7d796A366Cf1A

```

Run the interact script:

```
just interact 0x03C2865B77AbDC566f85DfDF02C7d796A366Cf1A
```

## Debugging

Edit `.env` to enable DEBUG logging:

```
RUST_LOG=DEBUG
```
