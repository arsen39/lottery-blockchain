interface IPassport {
   function register(string memory _username) external;
   function gainXP(address _user, uint256 _amount) external;
}