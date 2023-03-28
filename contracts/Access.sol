pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

/// @notice You should use as owner for this contract multisig wallet with 2-3 owners (f.e. Gnosis Safe)
contract Access is
    Initializable,
    AccessControlUpgradeable,
    OwnableUpgradeable
{
    mapping(bytes32 => address) public addressBook;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize() external initializer {
        __Ownable_init();
        __AccessControl_init();
    }

    function grantRole(bytes32 role, address account)
        public
        virtual
        override
        onlyOwner
    {
        _grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account)
        public
        virtual
        override
        onlyOwner
    {
        _revokeRole(role, account);
    }

    function setAddressItem(bytes32 key, address value) external onlyOwner {
        addressBook[key] = value;
    }

    function registerUser(address user) external {
        require(msg.sender == addressBook["PASSPORT_ADDRESS"],
            "Access: Invalid sender");
        _grantRole(keccak256("REGISTERED_USER_ROLE"), user);
    }
}

//________________
// GLOBAL_ADMIN_ROLE
// GLOBAL_MANAGER_ROLE
// SYSTEM_CONTRACT_ROLE
// REGISTERED_USER_ROLE
//________________
// UTILITY_TOKEN_ADDRESS
// COMMUNITY_WALLET_ADDRESS
// RANDOM_ADDRESS
// LOTTERY_ADDRESS
// PASSPORT_ADDRESS
//________________
// bytes32 public constant GLOBAL_ADMIN_ROLE = keccak256("GLOBAL_ADMIN_ROLE");
