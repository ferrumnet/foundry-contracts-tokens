// spdx-license-identifier: mit
pragma solidity 0.8.20;

import "./IGenericUpgradableToken.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract GenericUpgradableToken is ERC20BurnableUpgradeable,
	OwnableUpgradeable, IGenericUpgradableToken {

    function init(string memory _name, string memory _symbol,
        uint256 _totalSupply, address mintTarget, address owner)
    external override initializer {
        __Context_init_unchained();
        __ERC20_init_unchained(_name, _symbol);
        __ERC20Burnable_init_unchained();
        __Ownable_init_unchained(owner);
        _mint(mintTarget, _totalSupply);
    }
}
