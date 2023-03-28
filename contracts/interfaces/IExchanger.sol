interface IExchanger {
    function deposit(address _token, uint256 _amount) external returns (uint256);
    function withdraw(address _sender, uint256 _amount) external returns (bool);
    function checkStable(address _token) external view returns (bool);
}
