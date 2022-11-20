#!/usr/bin/env bash
set -e

HERE=.
CONTRACTSDIR=./start/contracts/

rm -rf start
cp -r start-annotated start

sed '/^[[:blank:]]*\/\/ TODO/d;s/\/\/ TODO.*//' $CONTRACTSDIR/Admin.sol > temp
mv temp $CONTRACTSDIR/Admin.sol
sed '/^[[:blank:]]*\/\/ TODO/d;s/\/\/ TODO.*//' $CONTRACTSDIR/PauseMeV1.sol > temp
mv temp $CONTRACTSDIR/PauseMeV1.sol
sed '/^[[:blank:]]*\/\/ TODO/d;s/\/\/ TODO.*//' $CONTRACTSDIR/PauseMeV2.sol > temp
mv temp $CONTRACTSDIR/PauseMeV2.sol
sed '/^[[:blank:]]*\/\/ TODO/d;s/\/\/ TODO.*//' $CONTRACTSDIR/FlashLoanV1.sol > temp
mv temp $CONTRACTSDIR/FlashLoanV1.sol
sed '/^[[:blank:]]*\/\/ TODO/d;s/\/\/ TODO.*//' $CONTRACTSDIR/FlashLoanV2.sol > temp
mv temp $CONTRACTSDIR/FlashLoanV2.sol
sed '/^[[:blank:]]*\/\/ TODO/d;s/\/\/ TODO.*//' $CONTRACTSDIR/UpgradeProxy.sol > temp
mv temp $CONTRACTSDIR/UpgradeProxy.sol


