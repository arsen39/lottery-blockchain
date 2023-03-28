pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "./lib/IPancakePair.sol";
import "./interfaces/IRandom.sol";

contract Random is Initializable, IRandom {
    uint256 private _seed;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(uint256 seed) external initializer {
        _seed = seed;
    }

    function getRandomV1(uint256 range)
        external
        view
        override
        returns (uint256)
    {
        bytes32 _dataSeed = _dataSeedGetter();
        uint256 rand = uint256(keccak256(abi.encode(_dataSeed)));
        return rand % range;
    }

    function getRandomV2(uint256 range, bytes32 _seed)
        external
        view
        override
        returns (uint256)
    {
        bytes32 _dataSeed = _dataSeedGetter();
        uint256 rand = uint256(keccak256(abi.encode(_dataSeed, _seed)));
        return rand % range;
    }

    function getRandomV3(
        uint256 range,
        bytes32 _seed1,
        uint256 _seed2,
        address _seed3
    ) external view override returns (uint256) {
        bytes32 _dataSeed = _dataSeedGetter();
        uint256 rand = uint256(
            keccak256(abi.encode(_dataSeed, _seed1, _seed2, _seed3))
        );
        return rand % range;
    }

    function getRandomV4(
        uint256 range,
        bytes32 _seed1,
        uint256 _seed2,
        address _seed3
    ) external view override returns (uint256) {
        bytes32 _priceSeed = _priceSeedGetter();
        bytes32 _dataSeed = _dataSeedGetter();
        uint256 rand = uint256(
            keccak256(
                abi.encode(_dataSeed, _priceSeed, _seed1, _seed2, _seed3)
            )
        );
        return rand % range;
    }

    function getPriceHash() external view override returns (bytes32) {
        return _priceSeedGetter();
    }

    function getDataHash() external view override returns (bytes32) {
        return _dataSeedGetter();
    }

    function _priceSeedGetter() internal view returns (bytes32 priceSeed) {
        address[4] memory pairs = [
            0x0eD7e52944161450477ee417DE9Cd3a859b14fD0,
            0x804678fa97d91B974ec2af3c843270886528a9E6,
            0xA39Af17CE4a8eb807E076805Da1e2B8EA7D0755b,
            0x58F876857a02D6762E0101bb5C46A8c1ED44Dc16
        ];

        bytes32[4] memory seeds;
        for (uint256 i = 0; i < 4; ) {
            IPancakePair pair = IPancakePair(pairs[i]);
            (uint112 reserve0, uint112 reserve1, uint32 timestamp) = pair
                .getReserves();
            uint256 price0CumulativeLast = pair.price0CumulativeLast();
            uint256 price1CumulativeLast = pair.price1CumulativeLast();
            uint256 kLast = pair.kLast();
            seeds[i] = keccak256(
                abi.encode(
                    reserve0,
                    reserve1,
                    timestamp,
                    price0CumulativeLast,
                    price1CumulativeLast,
                    kLast
                )
            );
            unchecked {
                i++;
            }
        }

        priceSeed = keccak256(
            abi.encode(seeds[0], seeds[1], seeds[2], seeds[3])
        );
    }

    function _dataSeedGetter() internal view returns (bytes32 dataSeed) {
        dataSeed = keccak256(
            abi.encode(
                block.timestamp,
                block.number,
                tx.origin,
                msg.sender,
                _seed
            )
        );
    }
}
