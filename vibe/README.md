## Vibe Code Exmple

**THIS CODE HAS KNOWN ISSUES**

**DO NOT USE THIS CODE IN PRODUCTION**

The code was generated using Cursor, configured with Agent `GPT-5.2 Codex`.

To start I did:

```
mkdir vibe
cd vibe
forge init
```

Then in Cursor I used the following prompt:

```
The project is a forge default project in Solidity. I want to create a staking system that will run on Ethereum. People deposit Eth. They can withdraw their Eth after a one week delay. There is a set of governers. A threshold number of them can indicate that a staker should be slashed. The slashing can occur up until the end of the withdrawal period.
```

I then ran tests using `forge test`. This resulted in two of the four tests failing. I then used the prompt:

```
when I run the tests, testSlashDuringWithdrawalDelay and testThresholdRequiresMultipleVotes fail
```

The result is what is in this repo. 

Questions for you, the reader:

* What problems do you see with this code?
* Can you see some minor bugs?
* How many major security issues do you see?

