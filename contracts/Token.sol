pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "./interfaces/IExchanger.sol";
import "./lib/TransferHelper.sol";

contract Token is Initializable, ERC20Upgradeable, OwnableUpgradeable {
    uint256 public constant coefficient = 20;
    address public exchanger;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address _exchanger) external initializer {
        __Ownable_init();
        __ERC20_init("Mellagio Token", "MELL");
        exchanger = _exchanger;
    }

    function setExchanger(address _exchanger) external onlyOwner {
        require(_exchanger != address(0), "Token: Invalid address");
        exchanger = _exchanger;
    }

    function deposit(uint256 amount, address stableToken) external {
        require(amount > 1e18, "Token: 1$ is minimum");
        require(
            IExchanger(exchanger).checkStable(stableToken),
            "Token: Stable token not supported"
        );
        TransferHelper.safeTransferFrom(
            stableToken,
            msg.sender,
            exchanger,
            amount
        );
        uint256 amountForMint = IExchanger(exchanger).deposit(
            stableToken,
            amount
        );
        _mint(msg.sender, amountForMint * coefficient);
    }

    function withdraw(uint256 amount) external {
        require(balanceOf(msg.sender) >= amount, "Token: Insufficient balance");
        _burn(msg.sender, amount);
        require(
            IExchanger(exchanger).withdraw(msg.sender, amount / coefficient),
            "Token: Withdraw failed"
        );
    }
}
