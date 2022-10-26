// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract DiceGame 
{
    Player private player1 = Player(address(0x0), 0, false);
    Player private player2 = Player(address(0x0), 0, false);
    address public winner;
    address public loser;
    bool public gameOver = false;
    uint private diceRoll;
    uint private prize;
    mapping(address => Commit) commits;

    struct Player 
    {
        address addr;
        uint number;
        bool numberSent;
    }

    struct Commit 
    {
        bytes32 hash;
        bool committed;
        bool checked;
    }

    function join() public payable 
    {
        require(player1.addr == address(0x0) || player2.addr == address(0x0));
        require(msg.value == 3, "Amount of 3 ETH needed to join the game");

        if (player1.addr == address(0x0)) {
            player1.addr = msg.sender;
        }
        else if (player2.addr == address(0x0)) {
            player2.addr = msg.sender;
            gameOver = false;
        }
    }

    function commit(bytes32 _hash) public 
    {
        require(msg.sender == player1.addr || msg.sender == player2.addr);
        Commit storage com = commits[msg.sender];
        require(com.committed == false, "Already committed");
        com.hash = _hash;
        com.committed = true;
        com.checked = false;
    }

    function sendNumber(uint _number, string memory _secret) public 
    {
        require(msg.sender == player1.addr || msg.sender == player2.addr); 
        Commit storage com1 = commits[player1.addr];
        Commit storage com2 = commits[player2.addr];
        require(com1.committed == true && com2.committed == true, "Both players not committed yet");

        Commit storage com = commits[msg.sender];
        require(!com.checked, "Number already sent");
        bytes32 hash = keccak256(abi.encodePacked(msg.sender, _number, _secret));
        require(hash == com.hash, "Hash doesn't match");

        if (msg.sender == player1.addr) {
            player1.number = _number;
            player1.numberSent = true;
        }
        else if (msg.sender == player2.addr) {
            player2.number = _number;
            player2.numberSent = true;
        }
        com.checked = true;
    }

    function revealWinner() public 
    {
        require(player1.numberSent && player2.numberSent);
        diceRoll = ((player1.number + player2.number) % 6) + 1;

        if (diceRoll == 1 || diceRoll == 2 || diceRoll == 3) {
            winner = player1.addr;
            prize = diceRoll;
        }
        else if (diceRoll == 4 || diceRoll == 5 || diceRoll == 6) {
            loser = player2.addr;
            prize = diceRoll - 3;
        }
    }

    function withdrawPrize() external 
    {
        require(msg.sender ==  winner, "Only the winner can claim the prize.");
        payable(msg.sender).transfer(prize);
        gameOver = true;
    }

    function withdrawRefund() external 
    {
        require(msg.sender == loser, "Only the loser can claim the leftover refund.");
        payable(msg.sender).transfer(address(this).balance - prize);
    }

    // function cancel() public
    // {
    //     require(!gameOver, "Game has already started.");

    //     gameOver = true;
    //     player1.addr = address(0x0);
    //     player2.addr = address(0x0);
    // }
    
}