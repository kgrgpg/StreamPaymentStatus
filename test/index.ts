import { expect, use } from "chai";
import { resolve } from "dns";
import { ethers } from "hardhat";

const WAD = "1000000000000000000";

describe("StreamPayment", function () {
  let owner: any;
  let user1: any;

  it("Test", async function () {
    const StreamPayment = await ethers.getContractFactory("StreamPayment");
    const streamPayment = await StreamPayment.deploy();
    await streamPayment.deployed();

    [owner, user1] = await ethers.getSigners();

    await streamPayment.connect(user1).pay(60,{
      from:user1.address,
      value:WAD
    });

    console.log("User address:",user1.address);
    const userBalance = (
      await ethers.provider.getBalance(user1.address)
    ).toString();

    console.log("User Balance:",userBalance);

    const contractBalance = (
      await ethers.provider.getBalance(streamPayment.address)
    ).toString();

    console.log("Contract balance",contractBalance);

    const lockBoxesCount = (
      await streamPayment.connect(user1).getLockBoxesCount()
    ).toNumber();

    console.log("Lock boxes count:",lockBoxesCount);

    for (let index = 0; index < lockBoxesCount; index++) {
      const box = (
        await streamPayment.connect(user1).getLockBox(index)
      ).toString();
      console.log("Lock Box:",box);
    }

    //Code as below to wait for 30 seconds and call claim

    // setTimeout(async ()=>{
    //   const claimLockBox = (
    //     await streamPayment.connect(user1).claim(1)
    //   ).toString();
  
    //   console.log("Claim status:", claimLockBox);
  
    //   for (let index = 0; index < lockBoxesCount; index++) {
    //     const box = (
    //       await streamPayment.connect(user1).getLockBox(index)
    //     ).toString();
    //     console.log("Lock Box:",box);
    //   }
    // },30000);

    // await new Promise((resolve,reject)=>{
    //   ethers.provider.on("block",(blockNumber)=>{
    //     console.log("Current block",blockNumber);
    //   })
    // });

    //Quick testing for redeem function as below
    // await streamPayment.connect(user1).redeem('700000000000000000000');
    // const userBalanceAfterRedeem = (
    //   await ethers.provider.getBalance(user1.address)
    // ).toString();

    // console.log("User Balance:",userBalanceAfterRedeem);

    // const contractBalanceAfterRedeem = (
    //   await ethers.provider.getBalance(streamPayment.address)
    // ).toString();

    // console.log("Contract balance",contractBalanceAfterRedeem);
  });
});