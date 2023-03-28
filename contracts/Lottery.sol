pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "./interfaces/IRandom.sol";
import "./interfaces/IAccess.sol";
import "./interfaces/IPassport.sol";
import "./lib/TransferHelper.sol";

contract Lottery is Initializable {
    uint256 public lotteriesCount;
    uint256 public tiketPrice;
    uint8[10] public prizes;
    address public access;

    mapping(uint256 => mapping(uint256 => address)) public numbers;

    event LotteryDraw(uint256 indexed lotteryId, uint256[10] numbers);
    event LotteryWin(uint256 indexed lotteryId, uint256 number, address winner);

    modifier onlyAdmin() {
        require(
            IAccess(access).hasRole(keccak256("GLOBAL_ADMIN_ROLE"), msg.sender),
            "Lottery: Invalid sender"
        );
        _;
    }

    modifier onlyManager() {
        require(
            IAccess(access).hasRole(
                keccak256("GLOBAL_MANAGER_ROLE"),
                msg.sender
            ),
            "Lottery: Invalid sender"
        );
        _;
    }

    modifier onlyRegisteredUsers() {
        require(
            IAccess(access).hasRole(
                keccak256("REGISTERED_USER_ROLE"),
                msg.sender
            ),
            "Lottery: Sender must be registered user"
        );
        _;
    }

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address _access) external initializer {
        access = _access;
        tiketPrice = 10 * 1e18;
        prizes = [30, 15, 10, 10, 10, 5, 5, 5, 5, 5];
    }

    function setTiketPrice(uint256 _price) external onlyAdmin {
        tiketPrice = _price;
    }

    function bet(uint256 _number) external onlyRegisteredUsers {
        require(_number >= 1000 && _number < 10000, "Lottery: Invalid number");
        require(
            numbers[lotteriesCount][_number] == address(0),
            "Lottery: Number already taken"
        );
        TransferHelper.safeTransferFrom(
            IAccess(access).addressBook("UTILITY_TOKEN_ADDRESS"),
            msg.sender,
            address(this),
            tiketPrice
        );
        IPassport(IAccess(access).addressBook("PASSPORT_ADDRESS")).gainXP(msg.sender, 10);
        numbers[lotteriesCount][_number] = msg.sender;
    }

    function draw() external onlyManager {
        address utilityToken = IAccess(access).addressBook(
            "UTILITY_TOKEN_ADDRESS"
        );
        address community = IAccess(access).addressBook(
            "COMMUNITY_WALLET_ADDRESS"
        );
        address random = IAccess(access).addressBook("RANDOM_ADDRESS");
        bytes32 priceHash = IRandom(random).getPriceHash();
        uint256 bank = IERC20(utilityToken).balanceOf(address(this));
        uint256 prize;
        uint256 lastNumber;
        uint256[10] memory lotteryNumbers;
        for (uint256 i = 0; i < 10; ) {
            uint256 number = (
                IRandom(random).getRandomV3(
                    8999,
                    priceHash,
                    lastNumber,
                    numbers[lotteriesCount][lastNumber]
                )
            ) + 1000;
            lastNumber = number;
            lotteryNumbers[i] = number;
            if (numbers[lotteriesCount][number] != address(0)) {
                prize = (bank * prizes[i]) / 100;
                TransferHelper.safeTransfer(
                    utilityToken,
                    numbers[lotteriesCount][number],
                    (prize * 99) / 100
                );
                TransferHelper.safeTransfer(
                    utilityToken,
                    community,
                    prize / 100
                );
                emit LotteryWin(
                    lotteriesCount,
                    number,
                    numbers[lotteriesCount][number]
                );
            }
            unchecked {
                i++;
            }
        }
        emit LotteryDraw(lotteriesCount, lotteryNumbers);
        lotteriesCount++;
    }
}
