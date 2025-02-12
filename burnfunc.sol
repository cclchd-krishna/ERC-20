// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import "token.sol";


contract BurnableToken is MyToken {

    function burn(uint256 amount) public returns (bool) {
        require(balances[msg.sender] >= amount, "Insufficient balance to burn");

        balances[msg.sender] -= amount;
        totalSupply -= amount;

        emit Transfer(msg.sender, address(0), amount);
        return true;
    }
}