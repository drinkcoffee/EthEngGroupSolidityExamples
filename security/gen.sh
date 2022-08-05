#!/usr/bin/env bash
set -e
#rm -rf build

HERE=.
BUILDDIR=$HERE/build
CONTRACTSDIR=./contracts/
OUTPUTDIR=$BUILDDIR/

solc $CONTRACTSDIR/Assert.sol --allow-paths . --bin-runtime --abi  --hashes --storage-layout --optimize -o $BUILDDIR --overwrite
solc $CONTRACTSDIR/TestToken.sol --allow-paths . --bin --abi  --hashes --storage-layout --optimize -o $BUILDDIR --overwrite
solc $CONTRACTSDIR/CrossContractCall.sol --allow-paths . --bin --abi  --hashes --storage-layout --optimize -o $BUILDDIR --overwrite
solc $CONTRACTSDIR/TryCatch.sol --allow-paths . --bin --abi  --hashes --storage-layout --optimize -o $BUILDDIR --overwrite
solc $CONTRACTSDIR/OverWrite.sol --allow-paths . --bin --abi  --hashes --storage-layout --optimize -o $BUILDDIR --overwrite
solc $CONTRACTSDIR/Code1.sol --allow-paths . --bin-runtime --abi  --hashes --storage-layout --optimize -o $BUILDDIR --overwrite
solc $CONTRACTSDIR/Code2.sol --allow-paths . --bin-runtime --abi  --hashes --storage-layout --optimize -o $BUILDDIR --overwrite
solc $CONTRACTSDIR/Choice.sol --allow-paths . --bin --abi  --hashes --storage-layout --optimize -o $BUILDDIR --overwrite
solc $CONTRACTSDIR/Loader.sol --allow-paths . --bin --abi  --hashes --storage-layout --optimize -o $BUILDDIR --overwrite


