#!/bin/bash
# Load the .env file if it exists
if [ -f .env ]
then
  set -a; source .env; set +a
fi

if [[ $useMainNet -eq 1 ]]
then
    echo Immutable zkEVM Mainnet Configuration
    RPC=https://rpc.immutable.com
    BLOCKSCOUT_URI=https://explorer.immutable.com/api?
    USEMAINNET=true
else
    echo Immutable zkEVM Testnet Configuration
    RPC=https://rpc.testnet.immutable.com
    BLOCKSCOUT_URI=https://explorer.testnet.immutable.com/api?
    USEMAINNET=false
fi
if [ -z "${BLOCKSCOUT_APIKEY}" ]; then
    echo "Error: BLOCKSCOUT_APIKEY environment variable is not set"
    exit 1
fi

if [[ $useLedger -eq 1 ]]
then
    echo " with Ledger Hardware Wallet"
    if [ -z "${LEDGER_HD_PATH}" ]; then
        echo "Error: LEDGER_HD_PATH environment variable is not set"
        exit 1
    fi
else
    echo " with a raw private key"
    if [ -z "${PRIVATE_KEY}" ]; then
        echo "Error: PRIVATE_KEY environment variable is not set"
        exit 1
    fi
fi


echo "Configuration"
echo " RPC: $RPC"
echo " BLOCKSCOUT_APIKEY: $BLOCKSCOUT_APIKEY"
echo " BLOCKSCOUT_URI: $BLOCKSCOUT_URI"
if [[ $useLedger -eq 1 ]]
then
    echo " LEDGER_HD_PATH: $LEDGER_HD_PATH"
else
    echo " PRIVATE_KEY: <not echoed for your security>" # $PRIVATE_KEY
fi



# NOTE WELL ---------------------------------------------
# Add resume option if the script fails part way through:
#     --resume \
# NOTE WELL ---------------------------------------------
if [[ $useLedger -eq 1 ]]
then
    forge script --rpc-url $RPC \
        --priority-gas-price 10000000000 \
        --with-gas-price     10000000100 \
        -vvv \
        --broadcast \
        --verify \
        --verifier blockscout \
        --verifier-url $BLOCKSCOUT_URI$BLOCKSCOUT_APIKEY \
        --sig "$FUNCTION_TO_EXECUTE" \
        --ledger \
        --hd-paths "$LEDGER_HD_PATH" \
        script/GameScript.s.sol:GameScript  
else
    forge script --rpc-url $RPC \
        --priority-gas-price 10000000000 \
        --with-gas-price     10000000100 \
        -vvv \
        --broadcast \
        --verify \
        --verifier blockscout \
        --verifier-url $BLOCKSCOUT_URI$BLOCKSCOUT_APIKEY \
        --sig "$FUNCTION_TO_EXECUTE" \
        --private-key $PRIVATE_KEY \
        script/GameScript.s.sol:GameScript  
fi
