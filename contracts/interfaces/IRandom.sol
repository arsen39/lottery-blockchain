pragma solidity ^0.8.0;

interface IRandom {
    // function getRandomV1(uint256 range, uint256 _number, address _address) external view returns (uint256);
    function getRandomV1(uint256 range) external view returns (uint256);

    function getRandomV2(uint256 range, bytes32 _seed1)
        external
        view
        returns (uint256);

    function getRandomV3(
        uint256 range,
        bytes32 _seed1,
        uint256 _seed2,
        address _seed3
    ) external view returns (uint256);

    function getRandomV4(
        uint256 range,
        bytes32 _seed1,
        uint256 _seed2,
        address _seed3
    ) external view returns (uint256);

    function getPriceHash() external view returns (bytes32);

    function getDataHash() external view returns (bytes32);
}
