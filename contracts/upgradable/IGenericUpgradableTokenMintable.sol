// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

interface IGenericUpgradableTokenMintable {
    function updateTotalSupply(address to, uint256 newTotalSupply) external;
}