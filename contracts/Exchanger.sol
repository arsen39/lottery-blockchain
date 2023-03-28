pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "./interfaces/IExchanger.sol";
import "./interfaces/IAccess.sol";
import "./lib/TransferHelper.sol";
import "./lib/IUniswapV2Router02.sol";
import "./lib/IShef.sol";

contract Exchanger is Initializable, IExchanger {
    uint256 public BUSD_USDT_PID;
    address public access;
    address public pancakeRouter;
    address public pancakeShef;
    address public BUSD;
    address public USDT;
    address public CAKE;
    address public BUSD_USDT_LP;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address _access) external initializer {
        access = _access;
        pancakeRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        pancakeShef = 0xa5f8C5Dbd5F286960b9d90548680aE5ebFf07652;
        BUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
        USDT = 0x55d398326f99059fF775485246999027B3197955;
        CAKE = 0x0E09FaBB73Bd3Ade0a17ECC321fD13a19e81cE82;
        BUSD_USDT_LP = 0x7EFaEf62fDdCCa950418312c6C91Aef321375A00;
        BUSD_USDT_PID = 7;
    }

    function deposit(address _tokenA, uint256 _amount)
        external
        override
        returns (uint256)
    {
        require(
            msg.sender == IAccess(access).addressBook("UTILITY_TOKEN_ADDRESS"),
            "Exchanger: Invalid sender"
        );
        require(checkStable(_tokenA), "Exchanger: Invalid token");
        address[] memory path = new address[](2);
        path[0] = _tokenA;
        if (_tokenA == BUSD) {
            path[1] = USDT;
        } else if (_tokenA == USDT) {
            path[1] = BUSD;
        }
        uint256 tokenPrevBalance = IERC20(path[1]).balanceOf(address(this));
        TransferHelper.safeApprove(_tokenA, pancakeRouter, _amount);
        IUniswapV2Router02(pancakeRouter).swapExactTokensForTokens(
            _amount / 2,
            (_amount * 48) / 100,
            path,
            address(this),
            block.timestamp
        );
        uint256 tokenCurrBalance = IERC20(path[1]).balanceOf(address(this)) -
            tokenPrevBalance;
        uint256 lpPrevBalance = IERC20(BUSD_USDT_LP).balanceOf(address(this));
        TransferHelper.safeApprove(path[1], pancakeRouter, tokenCurrBalance);
        IUniswapV2Router02(pancakeRouter).addLiquidity(
            path[0],
            path[1],
            _amount / 2,
            tokenCurrBalance,
            0,
            0,
            address(this),
            block.timestamp
        );
        uint256 lpCurrBalance = IERC20(BUSD_USDT_LP).balanceOf(address(this)) -
            lpPrevBalance;
        TransferHelper.safeApprove(BUSD_USDT_LP, pancakeShef, lpCurrBalance);
        IShef(pancakeShef).deposit(BUSD_USDT_PID, lpCurrBalance);
        _cakesHandler();
        return lpCurrBalance;
    }

    function withdraw(address _sender, uint256 _amount)
        external
        override
        returns (bool)
    {
        require(
            msg.sender == IAccess(access).addressBook("UTILITY_TOKEN_ADDRESS"),
            "Exchanger: Invalid sender"
        );
        IShef(pancakeShef).withdraw(BUSD_USDT_PID, _amount);
        TransferHelper.safeApprove(BUSD_USDT_LP, pancakeRouter, _amount);
        IUniswapV2Router02(pancakeRouter).removeLiquidity(
            BUSD,
            USDT,
            _amount,
            0,
            0,
            _sender,
            block.timestamp
        );
        _cakesHandler();
        return true;
    }

    function checkStable(address _token) public view override returns (bool) {
        return _token == BUSD || _token == USDT;
    }

    function _cakesHandler() internal {
        uint256 cakes = IERC20(CAKE).balanceOf(address(this));
        if (cakes > 0) {
            TransferHelper.safeTransfer(
                CAKE,
                IAccess(access).addressBook("COMMUNITY_WALLET_ADDRESS"),
                cakes
            );
        }
    }
}
