// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract FlexibleStaking is ERC20 {

    mapping(address => uint256) public staked;
    mapping(address => uint256) private stakedFromTS;
    
    constructor() ERC20("Flexible Staking", "FXX") {
        _mint(msg.sender,1000);
    }

    function stake(uint256 amount) external {
        require(amount > 0, "the amount is too low");
        require(balanceOf(msg.sender) >= amount, "balance is too low");
        _transfer(msg.sender, address(this), amount);
        if (staked[msg.sender] > 0) {
            claim();
        }
        stakedFromTS[msg.sender] = block.timestamp;
        staked[msg.sender] += amount;
    }

    function unstake(uint256 amount) external {
        require(amount > 0, "amount is <= 0");
        require(staked[msg.sender] >= amount, "amount is > staked");
        claim();
        staked[msg.sender] -= amount;
        _transfer(address(this), msg.sender, amount);
    }

    function claim() public {
        require(staked[msg.sender] > 0, "staked is <= 0");
        uint256 secondsStaked = block.timestamp - stakedFromTS[msg.sender];

        if (secondsStaked < 2.592e6) {
            uint256 rewards = staked[msg.sender] * secondsStaked / 3.154e7;

            uint256 reward =  rewards / 10;
            _mint(msg.sender,reward); 
            // 10% rate for staking periods less than a month
        } else if (secondsStaked < 7.776e6) {
            uint256 rewards = staked[msg.sender] * secondsStaked / 3.154e7;

            uint256 reward =  rewards / 4;
            _mint(msg.sender,reward); 
            // 25% rate for staking periods less than 3 months
        } else if (secondsStaked < 1.555e7) {
            uint256 rewards = staked[msg.sender] * secondsStaked / 3.154e7;

            uint256 reward =  rewards / 2;
            _mint(msg.sender,reward); 
            // 50% rate for staking periods less than six months
        } else {
            uint256 rewards = staked[msg.sender] * secondsStaked / 3.154e7;

            _mint(msg.sender,rewards); 
            // 100% rate for staking periods longer than six months
        }
        
        stakedFromTS[msg.sender] = block.timestamp;
    }

}

