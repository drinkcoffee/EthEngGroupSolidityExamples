#!/usr/bin/env bash
set -e
#rm -rf build

HERE=.
BUILDDIR=$HERE/build
CONTRACTSDIR=./contracts/
OUTPUTDIR=$BUILDDIR/

solc $CONTRACTSDIR/AbiDecode.sol --allow-paths . --bin-runtime --abi  --hashes --storage-layout --optimize -o $BUILDDIR --overwrite


