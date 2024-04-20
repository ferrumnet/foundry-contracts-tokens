// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

abstract contract FeeConfigurable is Initializable, OwnableUpgradeable {
    enum TransferType { NONE, RECEIVE, SEND, BOTH }

    struct FeeInfo {
        uint112 receivingFee;
        uint112 sendingFee;
        TransferType transferType; // 1 for receive, 2 for send, 3 for both
    }

    struct FeeConfigurableStorage {
        bool paused;
        mapping(address => FeeInfo) feeInfo;
        FeeInfo defaultFee;
        address taxDistributor;
    }

    // keccak256(abi.encode(uint256(keccak256("ferrum.storage.FeeConfigurable")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant FeeConfigurableStorageLocation = 0x3bd12cb73d7d24ea9acd32f63babe73bf454bd684946177f027b25a8053e3b00;

    function _getFeeConfigurableStorage() internal pure returns (FeeConfigurableStorage storage $) {
        assembly {
            $.slot := FeeConfigurableStorageLocation
        }
    }

    modifier whenNotPaused() {
        FeeConfigurableStorage storage $ = _getFeeConfigurableStorage();
        require(!$.paused, "FC: Contract is paused");
        _;
    }

    function __FeeConfigurable_init_unchained(address _taxDistributor) internal initializer {
        require(_taxDistributor != address(0), "FC: taxDist required");
        FeeConfigurableStorage storage $ = _getFeeConfigurableStorage();
        $.taxDistributor = _taxDistributor;
    }

    function taxDistributor() external view returns (address) {
        FeeConfigurableStorage storage $ = _getFeeConfigurableStorage();
        return $.taxDistributor;
    }

    function paused() external view returns (bool) {
        FeeConfigurableStorage storage $ = _getFeeConfigurableStorage();
        return $.paused;
    }

    function defaultfee() external view returns (FeeInfo memory) {
        FeeConfigurableStorage storage $ = _getFeeConfigurableStorage();
        return $.defaultFee;
    }

    function feeInfo(address target) external view returns (FeeInfo memory) {
        FeeConfigurableStorage storage $ = _getFeeConfigurableStorage();
        return $.feeInfo[target];
    }

    function pause() public onlyOwner {
        FeeConfigurableStorage storage $ = _getFeeConfigurableStorage();
        $.paused = true;
    }

    function unPause() public onlyOwner {
        FeeConfigurableStorage storage $ = _getFeeConfigurableStorage();
        $.paused = false;
    }

    function setTaxDistributor(address _taxDistributor) external onlyOwner {
        FeeConfigurableStorage storage $ = _getFeeConfigurableStorage();
        $.taxDistributor = _taxDistributor;
    }

    function configureDefaultFee(
        TransferType transferType,
        uint112 sendingFee,
        uint112 receivingFee
    ) external onlyOwner {
        require(transferType <= TransferType.BOTH, "Invalid transfer type");
        FeeConfigurableStorage storage $ = _getFeeConfigurableStorage();
        $.defaultFee = FeeInfo({
            receivingFee: receivingFee,
            sendingFee: sendingFee,
            transferType: transferType
        });
    }

    function configureFee(
        address targetAddr,
        TransferType transferType,
        uint112 sendingFee,
        uint112 receivingFee
    ) external onlyOwner {
        require(transferType <= TransferType.BOTH, "Invalid transfer type");
        FeeConfigurableStorage storage $ = _getFeeConfigurableStorage();
        $.feeInfo[targetAddr] = FeeInfo({
            receivingFee: receivingFee,
            sendingFee: sendingFee,
            transferType: transferType
        });
    }
}
