// spdx-license-identifier: mit
pragma solidity 0.8.20;

import "./IGenericUpgradableToken.sol";
import "./IGenericUpgradableTokenMintable.sol";
import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

contract FerrumProxyTokenDeployer {
	event TokenDeployed(address token, bytes data);
	event ProxyContsuctorArgs(bytes args);
	function deployToken(
		address logic, string memory name, string memory symbol,
		uint256 totalSupply, address admin) external returns (address)
	{
		bytes memory data = abi.encodeWithSelector(IGenericUpgradableToken.init.selector,
			name, symbol, totalSupply, msg.sender, admin
		);
		address token = address(new TransparentUpgradeableProxy{
			salt: keccak256(abi.encode(name, symbol, msg.sender))}(
			logic, admin, data
		));
		emit TokenDeployed(token, data);
		bytes memory args = abi.encode(logic, admin, data);
		emit ProxyContsuctorArgs(args);
		return token;
	}

	function updateTotalSupplyMethodData(
		address to, uint256 newTotalSupply
	) external pure returns (bytes memory data) {
		data = abi.encodeWithSelector(IGenericUpgradableTokenMintable.updateTotalSupply.selector,
			to, newTotalSupply);
	}
}