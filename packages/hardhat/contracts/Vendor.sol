pragma solidity 0.8.13;
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "./YourToken.sol";

contract Vendor is Ownable {

  event BuyTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokens);
  event SellTokens(address seller, uint256 amountOfETH, uint256 amountOfTokens);

  YourToken public yourToken;
  uint256 public constant tokensPerEth = 100;

  constructor(address tokenAddress) {
    yourToken = YourToken(tokenAddress);
  }

  function buyTokens() external payable {
    uint256 tokensBought = msg.value * tokensPerEth;
    yourToken.transfer(msg.sender, tokensBought);
    emit BuyTokens(msg.sender, msg.value, tokensBought);
  }

  function withdraw() external onlyOwner {
    uint256 ownerBalance = address(this).balance;
    require(ownerBalance > 0, "Owner has no balance to withdraw");

    (bool sent, ) = msg.sender.call{value: ownerBalance}("");
    require(sent, "Failed to send balance");
  }

  function sellTokens(uint256 _amount) public {
    yourToken.transferFrom(msg.sender, address(this), _amount);

    uint256 ethToReturn = _amount / tokensPerEth;

    (bool sent, ) = msg.sender.call{value: ethToReturn }("");
    require(sent, "Failed to send balance");
    emit SellTokens(msg.sender, ethToReturn, _amount);
  }
}
