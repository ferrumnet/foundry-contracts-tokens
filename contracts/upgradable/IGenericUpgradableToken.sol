// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

interface IGenericUpgradableToken {
		function init(string memory _name, string memory _symbol,
			uint256 _totalSupply, address owner, address admin) external;
}
