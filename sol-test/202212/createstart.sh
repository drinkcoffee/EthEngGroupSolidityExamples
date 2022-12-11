#!/usr/bin/env bash
set -e

HERE=.
CONTRACTSDIR=./start/contracts/

rm -rf start
rm -rf start-annotated/build
cp -r start-annotated start

sed '/^[[:blank:]]*\/\/ TODO/d;s/\/\/ TODO.*//' $CONTRACTSDIR/Admin.sol > temp.txt
mv temp.txt $CONTRACTSDIR/Admin.sol

sed '/^[[:blank:]]*\/\/ TODO/d;s/\/\/ TODO.*//' $CONTRACTSDIR/PauseMeV1.sol > temp.txt
mv temp.txt $CONTRACTSDIR/PauseMeV1.sol
sed '/^[[:blank:]]*\/\/ TODO/d;s/\/\/ TODO.*//' $CONTRACTSDIR/PauseMeV2.sol > temp.txt
mv temp.txt $CONTRACTSDIR/PauseMeV2.sol
sed '/^[[:blank:]]*\/\/ TODO/d;s/\/\/ TODO.*//' $CONTRACTSDIR/FlashLoanV1.sol > temp.txt
mv temp.txt $CONTRACTSDIR/FlashLoanV1.sol
sed '/^[[:blank:]]*\/\/ TODO/d;s/\/\/ TODO.*//' $CONTRACTSDIR/FlashLoanV2.sol > temp.txt
mv temp.txt $CONTRACTSDIR/FlashLoanV2.sol
sed '/^[[:blank:]]*\/\/ TODO/d;s/\/\/ TODO.*//' $CONTRACTSDIR/FlashLoanBase.sol > temp.txt
mv temp.txt $CONTRACTSDIR/FlashLoanBase.sol
sed '/^[[:blank:]]*\/\/ TODO/d;s/\/\/ TODO.*//' $CONTRACTSDIR/UpgradeProxy.sol > temp.txt
mv temp.txt $CONTRACTSDIR/UpgradeProxy.sol

sed '/^[[:blank:]]*\/\/ TODO/d;s/\/\/ TODO.*//' $CONTRACTSDIR/PauseMeBase.sol > temp.txt
mv temp.txt $CONTRACTSDIR/PauseMeBase.sol

sed '/^[[:blank:]]*\/\/ TODO/d;s/\/\/ TODO.*//' $CONTRACTSDIR/test/TestFlashLoanV1.sol > temp.txt
mv temp.txt $CONTRACTSDIR/test/TestFlashLoanV1.sol
sed '/^[[:blank:]]*\/\/ TODO/d;s/\/\/ TODO.*//' $CONTRACTSDIR/test/TestFlashLoanV2.sol > temp.txt
mv temp.txt $CONTRACTSDIR/test/TestFlashLoanV2.sol


grep -r TODO start | grep sol


