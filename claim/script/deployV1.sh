#!/bin/bash
# useMainNet: 1 for mainnet, 0 for testnet
useMainNet=1
# useLedger: 1 for ledger, 0 for private key
useLedger=1

LEDGER_HD_PATH="m/44'/60'/0'/0/1" 

FUNCTION_TO_EXECUTE='deployV1()'

# Set-up variables and execute forge
source $(dirname "$0")/common.sh
