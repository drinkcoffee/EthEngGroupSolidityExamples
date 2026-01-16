// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract EthStaking {
    uint256 public constant WITHDRAWAL_DELAY = 7 days;

    error NotOwner();
    error NotGovernor();
    error InvalidAmount();
    error ExistingWithdrawal();
    error NoWithdrawal();
    error WithdrawalNotReady(uint256 readyAt);
    error WithdrawalPeriodEnded(uint256 endAt);
    error InsufficientStake();
    error AlreadyVoted();
    error InvalidThreshold();
    error InvalidGovernor();
    error InvalidReceiver();
    error Reentrancy();

    event Deposited(address indexed staker, uint256 amount);
    event WithdrawalRequested(address indexed staker, uint256 amount, uint256 availableAt);
    event Withdrawn(address indexed staker, uint256 amount);
    event GovernorUpdated(address indexed governor, bool active);
    event SlashThresholdUpdated(uint256 threshold);
    event SlashReceiverUpdated(address indexed receiver);
    event SlashSignaled(address indexed staker, address indexed governor, uint256 votes, uint256 threshold);
    event Slashed(address indexed staker, uint256 amount);

    address public owner;
    address public slashReceiver;
    uint256 public slashThreshold;
    uint256 public governorCount;

    mapping(address => bool) public isGovernor;
    mapping(address => uint256) public stakeBalance;

    struct WithdrawalRequest {
        uint256 amount;
        uint256 requestedAt;
    }

    mapping(address => WithdrawalRequest) public withdrawals;

    mapping(address => uint256) public slashRound;
    mapping(address => mapping(address => uint256)) public slashVoteRound;
    mapping(address => uint256) public slashVoteCount;

    uint256 private reentrancyLock = 1;

    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert NotOwner();
        }
        _;
    }

    modifier onlyGovernor() {
        if (!isGovernor[msg.sender]) {
            revert NotGovernor();
        }
        _;
    }

    modifier nonReentrant() {
        if (reentrancyLock != 1) {
            revert Reentrancy();
        }
        reentrancyLock = 2;
        _;
        reentrancyLock = 1;
    }

    constructor(address[] memory initialGovernors, uint256 threshold, address receiver) payable {
        if (receiver == address(0)) {
            revert InvalidReceiver();
        }

        owner = msg.sender;
        slashReceiver = receiver;

        uint256 length = initialGovernors.length;
        for (uint256 i = 0; i < length; i++) {
            address governor = initialGovernors[i];
            if (governor == address(0)) {
                revert InvalidGovernor();
            }
            if (!isGovernor[governor]) {
                isGovernor[governor] = true;
                governorCount++;
                emit GovernorUpdated(governor, true);
            }
        }

        if (threshold == 0 || threshold > governorCount) {
            revert InvalidThreshold();
        }
        slashThreshold = threshold;
        emit SlashThresholdUpdated(threshold);
        emit SlashReceiverUpdated(receiver);
    }

    receive() external payable {
        deposit();
    }

    function setGovernor(address governor, bool active) external onlyOwner {
        if (governor == address(0)) {
            revert InvalidGovernor();
        }

        if (active) {
            if (!isGovernor[governor]) {
                isGovernor[governor] = true;
                governorCount++;
                emit GovernorUpdated(governor, true);
            }
        } else {
            if (isGovernor[governor]) {
                isGovernor[governor] = false;
                governorCount--;
                emit GovernorUpdated(governor, false);
            }
        }

        if (slashThreshold == 0 || slashThreshold > governorCount) {
            revert InvalidThreshold();
        }
    }

    function setSlashThreshold(uint256 newThreshold) external onlyOwner {
        if (newThreshold == 0 || newThreshold > governorCount) {
            revert InvalidThreshold();
        }
        slashThreshold = newThreshold;
        emit SlashThresholdUpdated(newThreshold);
    }

    function setSlashReceiver(address newReceiver) external onlyOwner {
        if (newReceiver == address(0)) {
            revert InvalidReceiver();
        }
        slashReceiver = newReceiver;
        emit SlashReceiverUpdated(newReceiver);
    }

    function deposit() public payable nonReentrant {
        if (msg.value == 0) {
            revert InvalidAmount();
        }
        if (slashRound[msg.sender] == 0) {
            slashRound[msg.sender] = 1;
        }
        stakeBalance[msg.sender] += msg.value;
        emit Deposited(msg.sender, msg.value);
    }

    function requestWithdrawal(uint256 amount) external nonReentrant {
        if (amount == 0) {
            revert InvalidAmount();
        }
        if (stakeBalance[msg.sender] < amount) {
            revert InsufficientStake();
        }
        if (withdrawals[msg.sender].amount != 0) {
            revert ExistingWithdrawal();
        }

        uint256 availableAt = block.timestamp + WITHDRAWAL_DELAY;
        withdrawals[msg.sender] = WithdrawalRequest({amount: amount, requestedAt: block.timestamp});
        emit WithdrawalRequested(msg.sender, amount, availableAt);
    }

    function withdraw() external nonReentrant {
        WithdrawalRequest memory request = withdrawals[msg.sender];
        if (request.amount == 0) {
            revert NoWithdrawal();
        }

        uint256 availableAt = request.requestedAt + WITHDRAWAL_DELAY;
        if (block.timestamp < availableAt) {
            revert WithdrawalNotReady(availableAt);
        }

        delete withdrawals[msg.sender];
        stakeBalance[msg.sender] -= request.amount;
        if (stakeBalance[msg.sender] == 0) {
            _resetSlashVotes(msg.sender);
        }

        (bool success, ) = msg.sender.call{value: request.amount}("");
        require(success, "WITHDRAW_FAILED");
        emit Withdrawn(msg.sender, request.amount);
    }

    function signalSlash(address staker) external onlyGovernor nonReentrant {
        if (stakeBalance[staker] == 0) {
            revert InsufficientStake();
        }

        WithdrawalRequest memory request = withdrawals[staker];
        if (request.amount != 0) {
            uint256 endAt = request.requestedAt + WITHDRAWAL_DELAY;
            if (block.timestamp >= endAt) {
                revert WithdrawalPeriodEnded(endAt);
            }
        }

        if (slashVoteRound[staker][msg.sender] == slashRound[staker]) {
            revert AlreadyVoted();
        }

        slashVoteRound[staker][msg.sender] = slashRound[staker];
        uint256 newVotes = slashVoteCount[staker] + 1;
        slashVoteCount[staker] = newVotes;
        emit SlashSignaled(staker, msg.sender, newVotes, slashThreshold);

        if (newVotes >= slashThreshold) {
            _slash(staker);
        }
    }

    function _slash(address staker) internal {
        uint256 amount = stakeBalance[staker];
        if (amount == 0) {
            return;
        }

        stakeBalance[staker] = 0;
        delete withdrawals[staker];
        _resetSlashVotes(staker);

        (bool success, ) = slashReceiver.call{value: amount}("");
        require(success, "SLASH_TRANSFER_FAILED");
        emit Slashed(staker, amount);
    }

    function _resetSlashVotes(address staker) internal {
        slashRound[staker] += 1;
        slashVoteCount[staker] = 0;
    }
}
