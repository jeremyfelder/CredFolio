pragma solidity ^0.4.18;

import "./EdHighSchool.sol";

contract EdCore is EdHighSchool{

    uint overFlowBalance = 0;
    uint prevWithdrawalBlockNum = block.number;
    uint16 expectedSecondsPerBlock = 15;
    uint numBlocksNeededForWithdrawal = 86400/expectedSecondsPerBlock;
    uint80 withdrawalLimit = 100000000000000000000;

    modifier canWithdraw(){
        require(block.number > prevWithdrawalBlockNum);
        require((block.number - prevWithdrawalBlockNum) > numBlocksNeededForWithdrawal);
        _;
    }

    function() external payable {}

    function setSPB(uint16 secsPerBlock) public onlyCEOorCTO {
        require(secsPerBlock >   0);
        expectedSecondsPerBlock = secsPerBlock;
    }

    function setWithdrawalLimit(uint32 limit) public onlyCEOorCFO{
        require(limit > 0);
        withdrawalLimit = limit;
    }

    function updateOverFlowBalance() internal returns (uint){
        uint balance = address(this).balance;
        if(balance > withdrawalLimit){
            overFlowBalance = balance - withdrawalLimit;
        }
        return overFlowBalance;
    }

    function withdraw(uint amount) onlyCEOorCFO canWithdraw public {
        require(amount > 0);
        uint amountInWei = amount*1e18;
        require(amountInWei / 1e18 == amount);
        require(amountInWei <= address(this).balance);
        require(amountInWei < withdrawalLimit);
        overFlowBalance  = updateOverFlowBalance();
        if(overFlowBalance > 0){
            if(amountInWei < overFlowBalance){
                overFlowBalance -= amountInWei;
            } else {
                overFlowBalance = 0;
            }
        }
        prevWithdrawalBlockNum = block.number;
        chiefExecutiveOfficer().transfer(withdrawalLimit);
    }
}
