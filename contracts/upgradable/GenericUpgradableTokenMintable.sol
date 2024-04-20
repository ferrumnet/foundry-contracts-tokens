// spdx-license-identifier: mit
pragma solidity 0.8.20;

import "./IGenericUpgradableTokenMintable.sol";
import "./GenericUpgradableToken.sol";

contract GenericUpgradableTokenMintable is GenericUpgradableToken, IGenericUpgradableTokenMintable {

    function updateTotalSupply(address to, uint256 newTotalSupply)
		public override virtual onlyOwner {
			uint256 amount = newTotalSupply - totalSupply();
			_mint(to, amount);
    }
}
