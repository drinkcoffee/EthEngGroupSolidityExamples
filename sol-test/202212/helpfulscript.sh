mkdir temp1
solc start/contracts/FlashLoanV1.sol --hashes > ./temp1/v1hashes.txt
solc start/contracts/FlashLoanV1.sol --storage-layout > ./temp1/v1storage.txt
solc start/contracts/FlashLoanV2.sol --hashes > ./temp1/v2hashes.txt
solc start/contracts/FlashLoanV2.sol --storage-layout > ./temp1/v2storage.txt
solc start/contracts/UpgradeProxy.sol --hashes > ./temp1/uphashes.txt
solc start/contracts/UpgradeProxy.sol --storage-layout > ./temp1/upstorage.txt


solc final/contracts/FlashLoanV1.sol --hashes > ./temp1/finalv1hashes.txt
solc final/contracts/FlashLoanV1.sol --storage-layout > ./temp1/finalv1storage.txt
solc final/contracts/FlashLoanV2.sol --hashes > ./temp1/finalv2hashes.txt
solc final/contracts/FlashLoanV2.sol --storage-layout > ./temp1/finalv2storage.txt
solc final/contracts/UpgradeProxy.sol --hashes > ./temp1/finaluphashes.txt
solc final/contracts/UpgradeProxy.sol --storage-layout > ./temp1/finalupstorage.txt

