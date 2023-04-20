#!/usr/bin/env bash
# set -e

HERE=.
CONTRACTSDIR=./start/contracts


rm -rf start
cp -r start-annotated start

sed '/^[[:blank:]]*\/\/ TODO/d;s/\/\/ TODO.*//' $CONTRACTSDIR/BadAuth.sol > temp.txt
mv temp.txt $CONTRACTSDIR/BadAuth.sol

sed '/^[[:blank:]]*\/\/ TODO/d;s/\/\/ TODO.*//' $CONTRACTSDIR/BadLogic.sol > temp.txt
mv temp.txt $CONTRACTSDIR/BadLogic.sol
sed '/^[[:blank:]]*\/\/ TODO/d;s/\/\/ TODO.*//' $CONTRACTSDIR/BadUpgrade.sol > temp.txt
mv temp.txt $CONTRACTSDIR/BadUpgrade.sol
sed '/^[[:blank:]]*\/\/ TODO/d;s/\/\/ TODO.*//' $CONTRACTSDIR/Reentrancy.sol > temp.txt
mv temp.txt $CONTRACTSDIR/Reentrancy.sol
sed '/^[[:blank:]]*\/\/ TODO/d;s/\/\/ TODO.*//' $CONTRACTSDIR/BadProxy.sol > temp.txt
mv temp.txt $CONTRACTSDIR/BadProxy.sol
sed '/^[[:blank:]]*\/\/ TODO/d;s/\/\/ TODO.*//' $CONTRACTSDIR/Inefficient.sol > temp.txt
mv temp.txt $CONTRACTSDIR/Inefficient.sol


grep -r TODO start | grep sol

# check everything compiles
solc $CONTRACTSDIR/BadAuth.sol
solc $CONTRACTSDIR/BadLogic.sol 
solc $CONTRACTSDIR/BadUpgrade.sol 
solc $CONTRACTSDIR/Reentrancy.sol
solc $CONTRACTSDIR/BadProxy.sol
solc $CONTRACTSDIR/Inefficient.sol



