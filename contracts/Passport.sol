pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "./interfaces/IAccess.sol";
import "./interfaces/IPassport.sol";
import "hardhat/console.sol";

contract Passport is
    Initializable,
    ReentrancyGuardUpgradeable,
    ERC721Upgradeable,
    IPassport
{
    uint256 _passportsAmount;
    string public baseURI;
    address public access;

    mapping(address => bool) public transfersWhitelist;
    mapping(address => uint256) public userId;
    mapping(address => string) public username;
    mapping(address => uint256) public regTimestamp;
    mapping(address => uint256) public xpAmount;

    event Register(
        address indexed to,
        uint256 indexed tokenId,
        string username
    );
    event GainXP(address indexed to, uint256 amount);

    modifier onlyAdmin() {
        require(
            IAccess(access).hasRole(keccak256("GLOBAL_ADMIN_ROLE"), msg.sender),
            "Passport: Invalid sender"
        );
        _;
    }

    modifier onlySystem() {
        require(
            IAccess(access).hasRole(
                keccak256("SYSTEM_CONTRACT_ROLE"),
                msg.sender
            ),
            "Passport: Invalid sender"
        );
        _;
    }

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address _access) external initializer {
        __ERC721_init("Mellagio Game Passport", "MGGP");
        __ReentrancyGuard_init();
        access = _access;
    }

    function setBaseURI(string memory _baseURILink) external onlyAdmin {
        baseURI = _baseURILink;
    }

    function register(string memory _username) external override nonReentrant {
        require(msg.sender.code.length == 0, "Passport: Contract not allowed");
        require(balanceOf(msg.sender) == 0, "Passport: Already registered");
        IAccess(access).registerUser(msg.sender);
        _safeMint(msg.sender, _passportsAmount);
        userId[msg.sender] = _passportsAmount;
        username[msg.sender] = _username;
        regTimestamp[msg.sender] = block.timestamp;
        emit Register(msg.sender, _passportsAmount, _username);
        _passportsAmount++;
    }

    function setTransferWhitelist(address _address, bool _status)
        external
        onlyAdmin
    {
        transfersWhitelist[_address] = _status;
    }

    function gainXP(address _user, uint256 _amount)
        external
        override
        onlySystem
    {
        xpAmount[_user] += _amount;
        emit GainXP(_user, _amount);
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public override {
        require(
            transfersWhitelist[to],
            "Transfer to this address is not allowed"
        );
        super.transferFrom(from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        require(
            transfersWhitelist[to],
            "Transfer to this address is not allowed"
        );
        super.safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) public virtual override {
        require(
            transfersWhitelist[to],
            "Transfer to this address is not allowed"
        );
        super.safeTransferFrom(from, to, tokenId, data);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override
        returns (string memory)
    {
        return string(abi.encodePacked(baseURI, tokenId));
    }

    function totalSupply() public view returns (uint256) {
        return _passportsAmount;
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }
}
