//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./StreamPayment.sol";

contract ShareToken is ERC20, Ownable{

    StreamPayment public immutable streamPayment;
    constructor(StreamPayment sp,string memory name, string memory symbol) ERC20(name, symbol) 
    {
        streamPayment = sp;
    }

    function mint (address to, uint256 amount) external onlyOwner {
    _mint(to, amount);
    }

  function burn (address holder, uint256 amount) external onlyOwner {
    _burn(holder, amount);
  }


}