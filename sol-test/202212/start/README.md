# Solidity Test: December 2022

The contracts folder holds the following files:

* Admin.sol: Allow a single account to manager a contract.
* FlashLoanV1.sol: Manages deposits and flash loans.
* FlashLoanV2.sol: Same as V1, but uses PauseMeV2.sol, and adds a constructor to call PauseMeV2.sol's constructor.
* PauseMeV1.sol: Pauses a contract.
* PauseMeV1.sol: Pauses a contract + have a pauser role.
* UpgradeProxy.sol: Transparent proxy that facilitates upgrade.

Note: A solution to resolve many of the issues in these contracts
is to use OpenZeppelin contracts. Candidates should point this out. 
However, the purpose of this exercise is to create a self-standing 
set of contracts.

The number of issues in the code is shown below. Issues that are common
between FlashLoanV1 and FlashLoanV2.sol are not counted.

* Basic: 15
* Intermediate: 7 
* Advanced: 5