#!/bin/bash
# Use the minting API. This can be accessed here: 
# https://docs.immutable.com/api/zkevm/reference/#/operations/GetMintRequest
# This only mints one NFT at a time. Multiple NFTs could be minted at once using the array of assets.

useMainNet=1

# Initial owner is the 14Numbers token reserve account
NEWOWNER=0x3f6C53488A4480EEf3793770f2a21d4ECA476db5

if [ ${useMainNet} -eq 1 ]
then
    echo Immutable zkEVM Mainnet Configuration
    API=https://api.immutable.com/
    CHAINNAME=imtbl-zkevm-mainnet
    // 14Numbers Scenes
    NFTCONTRACT=0x29c3a209d8423f9a53bf8ad39bbb85087a2a938b
else
    echo Immutable zkEVM Testnet Configuration
    API=https://api.sandbox.immutable.com/
    CHAINNAME=imtbl-zkevm-testnet
    // 14Numbers Scenes Test 
    NFTCONTRACT=0x1a8cBb0c5ADdA8345AdfC0d3B19D661236A4F709
fi

echo Immutable API Key: $IMMUTABLEAPIKEY
echo NFT Contract Address: $NFTCONTRACT
echo Owner of Minted NFTs: $NEWOWNER


if [ -z "${IMMUTABLEAPIKEY}" ]; then
    echo "Error: IMMUTABLEAPIKEY environment variable is not set"
    exit 1
fi
if [ -z "${NFTCONTRACT}" ]; then
    echo "Error: NFTCONTRACT environment variable is not set"
    exit 1
fi
if [ -z "${NEWOWNER}" ]; then
    echo "Error: NEWOWNER environment variable is not set"
    exit 1
fi


generate_post_data()
{
  cat <<EOF
{
  "assets": [
    {
      "reference_id": "100",
      "owner_address": "$NEWOWNER",
      "token_id": "100",
      "amount": "10",
      "metadata": {
        "name": "Golden Fans",
        "image": "https://whatgamestudios.github.io/14numbers/nfts/100goldenfans.png",
        "attributes": [
        {
            "trait_type": "Series",
            "value": "Gen1"
        },
        {
            "trait_type": "Rarity",
            "value": "Mythical"
        },
        {
            "trait_type": "Max Supply",
            "value": 10
        },
        {
            "trait_type": "Artist",
            "value": "Natata"
        }
      ]
      }
    },
    {
      "reference_id": "101",
      "owner_address": "$NEWOWNER",
      "token_id": "101",
      "amount": "25",
      "metadata": {
        "name": "Bright Cats",
        "image": "https://whatgamestudios.github.io/14numbers/nfts/101brightcats.png",
        "attributes": [
            {
                "trait_type": "Series",
                "value": "Gen1"
            },
            {
                "trait_type": "Rarity",
                "value": "Legendary"
            },
            {
                "trait_type": "Max Supply",
                "value": 25
            },
            {
                "trait_type": "Artist",
                "value": "Burbura"
            }
        ]
        }
    },
    {
      "reference_id": "102",
      "owner_address": "$NEWOWNER",
      "token_id": "102",
      "amount": "100",
      "metadata": {
        "name": "Mixed Flowers",
        "image": "https://whatgamestudios.github.io/14numbers/nfts/102fantasyflowers.png",
        "attributes": [
            {
                "trait_type": "Series",
                "value": "Gen1"
            },
            {
                "trait_type": "Rarity",
                "value": "Epic"
            },
            {
                "trait_type": "Max Supply",
                "value": 100
            },
            {
                "trait_type": "Artist",
                "value": "Elen Lane"
            }
        ]
        }
    },
    {
      "reference_id": "103",
      "owner_address": "$NEWOWNER",
      "token_id": "103",
      "amount": "1000",
      "metadata": {
        "name": "Yellow Flowers",
        "image": "https://whatgamestudios.github.io/14numbers/nfts/103yellowflowers.png",
        "tokenId": "103",
        "attributes": [
        {
            "trait_type": "Series",
            "value": "Gen1"
        },
        {
            "trait_type": "Rarity",
            "value": "Common"
        },
        {
            "trait_type": "Max Supply",
            "value": 1000
        },
        {
            "trait_type": "Artist",
            "value": "Unknown"
        }
        ]
        }
    }    
    
  ]
}
EOF
}

curl --request POST \
  --url ${API}v1/chains/${CHAINNAME}/collections/${NFTCONTRACT}/nfts/mint-requests \
  --header 'Accept: application/json' \
  --header 'Content-Type: application/json' \
  --header "x-immutable-api-key: ${IMMUTABLEAPIKEY}" \
  --data "$(generate_post_data)"

echo Minting API Call Done