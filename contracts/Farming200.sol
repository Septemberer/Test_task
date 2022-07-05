//SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

contract Farming200 {
    mapping(address => uint256) private user_info_amount; // (address -> amount)
    mapping(address => uint256) private user_info_time; // (address -> time)

    address public immutable owner;
    uint256 private reserve;

    constructor() payable {
        owner = msg.sender;
        reserve = msg.value;
    } // For the correct operation of the contract, a reserve of ether is needed

    // it will be everything that the creator of the contract will send during the deployment

    function getReserve() public view returns(uint256) {
        return reserve;
    }

    // Function for accepting user contributions
    function makePaymentFor200Days(uint256 _amount) external payable {
        address user = msg.sender;
        require(user_info_amount[user] == 0, "You have already contributed");
        require(msg.value >= _amount, "Insufficient funds have been deposited");
        user_info_amount[user] = _amount;
        user_info_time[user] = block.timestamp;
        reserve += _amount;
        if (msg.value > _amount) {
            payable(user).transfer(msg.value - _amount); // We return the surplus
        }
    }

    // Will issue a reward to the user only if 200 days have passed since the deposit
    function getReward() external {
        address user = msg.sender;
        uint256 amount = user_info_amount[user];

        require(amount > 0, "You didn't contribute anything");

        uint256 days200 = 60 * 60 * 24 * 200; // how many seconds in 200 days

        require(
            user_info_time[user] + days200 <= block.timestamp,
            "200 days have not passed"
        );

        uint256 reward = amount + ((amount * 200) / 100); // 1% for 200 days

        require(
            reserve >= reward,
            "There are not enough funds on the contract to pay the reward"
        );
        reserve -= reward;
        user_info_amount[user] = 0;
        user_info_time[user] = 0;

        payable(user).transfer(reward);
    }

    // To accept the sent ether into the contract reserve
    // (in case of transfer to the contract address as to a regular wallet)
    receive() external payable {
        reserve += msg.value;
    }
}
