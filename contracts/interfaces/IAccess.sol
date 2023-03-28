pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/IAccessControl.sol";
interface IAccess is IAccessControl {
    function addressBook(bytes32 key) external view returns (address);
    function registerUser(address user) external;
}
