// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/// @title ReentrantVault
/// @notice A minimal ETH vault. Users deposit and withdraw their own balance.
contract ReentrantVault {
    mapping(address => uint256) public balances;

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    /// @dev VULNERABLE: external call happens BEFORE the balance is zeroed,
    ///      so a malicious receiver can re-enter withdraw() and drain the vault.
    function withdraw() external {
        uint256 bal = balances[msg.sender];
        require(bal > 0, "no balance");
        (bool ok, ) = msg.sender.call{value: bal}("");
        require(ok, "transfer failed");
        balances[msg.sender] = 0;
    }

    receive() external payable {}
}