// spdx-license-identifier: mit
pragma solidity 0.8.20;

import "./GenericUpgradableToken.sol";
import "./FeeConfigurable.sol";

contract UpgradableTokenWithFee is GenericUpgradableToken, FeeConfigurable {
    function init(string memory _name, string memory _symbol,
        uint256 _totalSupply, address supplyTarget, address owner, address taxDistributor)
    external initializer {
        __Context_init_unchained();
        __ERC20_init_unchained(_name, _symbol);
        __ERC20Burnable_init_unchained();
        __Ownable_init_unchained(owner);
        __FeeConfigurable_init_unchained(taxDistributor);
        _mint(supplyTarget, _totalSupply);
    }

    function _update(address from, address to, uint256 amount) internal override whenNotPaused {
        FeeConfigurableStorage storage $ = _getFeeConfigurableStorage();
        FeeInfo memory senderFeeInfo = $.feeInfo[from];
        FeeInfo memory receiverFeeInfo = $.feeInfo[to];
        FeeInfo memory defaultFee = $.defaultFee;
        uint256 senderFee = 0;
        uint256 receiverFee = 0;

        if (senderFeeInfo.transferType == TransferType.BOTH || senderFeeInfo.transferType == TransferType.SEND) {
            senderFee = amount * senderFeeInfo.sendingFee / 10000;
            amount -= senderFee;
        }

        if (receiverFeeInfo.transferType == TransferType.BOTH || receiverFeeInfo.transferType == TransferType.RECEIVE) {
            receiverFee = amount * receiverFeeInfo.receivingFee / 10000;
            amount -= receiverFee;
        }

        if (senderFee == 0 && receiverFee == 0) {
            // If there is no fee override check the default fee
            if (defaultFee.transferType == TransferType.BOTH || defaultFee.transferType == TransferType.SEND) {
                senderFee = amount * defaultFee.sendingFee / 10000;
                amount -= senderFee;
            }

            if (defaultFee.transferType == TransferType.BOTH || defaultFee.transferType == TransferType.RECEIVE) {
                receiverFee = amount * defaultFee.receivingFee / 10000;
                amount -= receiverFee;
            }
        }

        super._update(from, to, amount);
        
        if (senderFee != 0 || receiverFee != 0) {
            super._transfer(from, $.taxDistributor, senderFee + receiverFee);
        }
    }
}