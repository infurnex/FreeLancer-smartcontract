// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract FreelancerContract {
    struct Work {
        address client;
        address freelancer;
        uint amount;
        bool completed;
    }

    mapping(uint => Work) public works;
    uint public workIndex;

    event FundsDeposited(address indexed client, uint indexed workIndex, uint amount);
    event WorkCompleted(uint indexed workIndex, address indexed freelancer, uint amount);
    event FundsWithdrawn(uint indexed workIndex, address indexed freelancer, uint amount);

    modifier onlyClient(uint _workIndex) {
        require(msg.sender == works[_workIndex].client, "Only client can perform this action");
        _;
    }

    modifier onlyFreelancer(uint _workIndex) {
        require(msg.sender == works[_workIndex].freelancer, "Only freelancer can perform this action");
        _;
    }

    function depositFunds(address _freelancer) external payable {
        require(msg.value > 0, "Sent amount should be greater than 0");
        workIndex++;
        works[workIndex] = Work({
            client: msg.sender,
            freelancer: _freelancer,
            amount: msg.value,
            completed: false
        });
        emit FundsDeposited(msg.sender, workIndex, msg.value);
    }

    function completeWork(uint _workIndex) external onlyClient(_workIndex) {
        require(works[_workIndex].completed == false, "Work has already been marked as completed");
        works[_workIndex].completed = true;
        emit WorkCompleted(_workIndex, works[_workIndex].freelancer, works[_workIndex].amount);
    }

    function withdrawFunds(uint _workIndex) external onlyFreelancer(_workIndex) {
        require(works[_workIndex].completed == true, "Work is not yet completed");
        uint amountToSend = works[_workIndex].amount;
        works[_workIndex].amount = 0;
        payable(works[_workIndex].freelancer).transfer(amountToSend);
        emit FundsWithdrawn(_workIndex, works[_workIndex].freelancer, amountToSend);
    }
}
