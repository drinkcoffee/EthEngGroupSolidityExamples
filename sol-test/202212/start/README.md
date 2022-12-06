# Solidity Test: December 2022

The code in this test provides a FlashLoan system. For a fee,
a user can loan Ether within a transaction. There are two versions
of the system: ```FlashLoanV1``` and ```FlashLoanV2```. The difference
between the two is that the functionality around pausing the system
has been improved for V2. The contracts are accessed via a transparant
upgrade proxy  ```UpgradeProxy```.

There are 3 advanced, 4 intermediate, and 3 beginner issues with the 
contracts. 

Note: A solution to resolve many of the issues in these contracts
is to use OpenZeppelin contracts. Candidates should point this out.
However, the purpose of this exercise is to create a self-standing
set of contracts.

To build and test:

1. Install Truffle: See: https://trufflesuite.com/docs/truffle/how-to/install/
2. Install Truffle asserts: ```npm install truffle-assertions```
3. Run tests: ```truffle test```

