// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract DiceGame {
    address public player1;
    address public player2;
    address public winner;
    address public loser;
    bool public gameOver;
    uint public diceRoll;
    uint public prize;
    

    event GameStarted();

    constructor() payable {
        require(msg.value == 3, "Amount of 3 ETH needed to start the game");
        player1 = msg.sender;
    }

    function join() public payable {
        require(player2 == address(0x0), "Game has already started");
        require(!gameOver, "Game was canceled.");
        require(msg.value == 3, "Amount of 3 ETH needed to join the game");

        player2 = msg.sender;

        emit GameStarted();
    }

    function cancel() public {
        require(!gameOver, "Game has already started.");

        gameOver = true;
    }

    function start() public {
        // function random
        diceRoll = 1;
        //

        if (diceRoll == 1 || diceRoll == 2 || diceRoll == 3) {
            prize = diceRoll + 3;
        }
        else if (diceRoll == 4 || diceRoll == 5 || diceRoll == 6) {
            prize = diceRoll;
        }
        gameOver = true;
    }

    function withdrawPrize() external {
        require(msg.sender ==  winner, "Only the winner can claim the prize.");
        payable(msg.sender).transfer(prize);
    }

    function withdrawRefund() external {
        require(msg.sender == loser, "Only the loser can claim the leftover refund.");
        payable(msg.sender).transfer(address(this).balance - prize);
    }
}