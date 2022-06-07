//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "./ShareToken.sol";

contract StreamPayment {

    uint256 WAD = 10**18;

    mapping (address => uint256) payees;

    ShareToken public immutable shareToken;

    address p1 = 0x047425F8d784DcC6d73df12bc6EECA3aA51F4Fb2;
    address p2 = 0x522EB82b8394F1ABc499bE2b986B79FeaF7E451e;

    //Test address
    // address p2 = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8;

    uint256 s1 = 300000000000000000;
    uint256 s2 = 700000000000000000;

    uint256 shareTokenPrice = 1000000000000000; //In terms of ETH

    struct LockBoxStruct {
        address beneficiary;
        uint256 initialDeposit;
        uint256 released;
        uint256 startTimestamp;
        uint256 duration;
    }

    LockBoxStruct[] public lockBoxStructs;
    
    constructor() {

        //Initialize the payees and their shares
        //Considering that this contract is dedicated for these payees and dynamic modification
        //of payees list and their shares is not required at the moment.

        uint256 whole = s1 + s2;
        assert(whole == WAD);

        payees[p1] = s1;
        payees[p2] = s2;

        //Initialize ShareToken
        shareToken = new ShareToken(this, "Share Token", "ST");
    }

    function pay(uint256 _duration) public payable{
        console.log("Ether transferred:",msg.value);
        console.log("Time duration:",msg.value);
        uint256 amountOfShareTokensToMint = msg.value * WAD / shareTokenPrice;
        console.log("Share tokens to mint:",amountOfShareTokensToMint);
        shareToken.mint(address(this),amountOfShareTokensToMint);

        uint256 p1Share = amountOfShareTokensToMint * payees[p1] / WAD;
        uint256 p2Share = amountOfShareTokensToMint * payees[p2] / WAD;
        console.log("P1 SHARE:",p1Share);
        console.log("P2 SHARE:",p2Share);
        
        LockBoxStruct memory lp1;
        lp1.beneficiary = p1;
        lp1.initialDeposit = p1Share;
        lp1.released = 0;
        lp1.startTimestamp = block.timestamp;
        lp1.duration = _duration;

        LockBoxStruct memory lp2;
        lp2.beneficiary = p2;
        lp2.initialDeposit = p2Share;
        lp2.released = 0;
        lp2.startTimestamp = block.timestamp;
        lp2.duration = _duration;

        lockBoxStructs.push(lp1);
        lockBoxStructs.push(lp2);
    }

    function redeem(uint256 shareTokensToRedeem) public payable{
        console.log("Share tokens to redeem:",shareTokensToRedeem);
        shareToken.burn(msg.sender,shareTokensToRedeem);
        uint256 ethToPay = shareTokensToRedeem * shareTokenPrice / WAD;
        console.log("Eth to pay:",ethToPay);
        payable(msg.sender).transfer(ethToPay);
    }

    function claim(uint lockBoxNumber) public returns(bool success){
        LockBoxStruct storage l = lockBoxStructs[lockBoxNumber];
        require(l.beneficiary == msg.sender);
        uint256 timestampAtClaim = block.timestamp;
        console.log("Timestamp at claim:",timestampAtClaim);
        require(timestampAtClaim > l.startTimestamp);
        if(timestampAtClaim <= l.startTimestamp + l.duration){
            uint256 x = ((l.initialDeposit/l.duration)*(timestampAtClaim-l.startTimestamp))-l.released;
            console.log("Tokens to be claimed:",x);
            shareToken.transfer(msg.sender,x);
            l.released += x;
        }
        else{
            uint256 x = l.initialDeposit - l.released;
            console.log("Tokens to be claimed:",x);
            shareToken.transfer(msg.sender,x);
            l.released += x;
        }
        return true;
    }

    function getLockBoxesCount() view public returns(uint){
        return lockBoxStructs.length;
    }

    function getLockBox(uint index) view public returns(address,uint256,uint256,uint256,uint256){
        LockBoxStruct storage l = lockBoxStructs[index];
        return (l.beneficiary,l.initialDeposit,l.released,l.startTimestamp,l.duration);
    }
}