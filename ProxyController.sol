pragma solidity ^0.5.5;


import "./DoToken.sol";
import "./DoAuth.sol";

contract ProxyController{
    

    DoToken a = DoToken(0x358AA13c52544ECCEF6B0ADD0f801012ADAD5eE3);
    DoAuth b = DoAuth(0xd2a5bC10698FD955D1Fe6cb468a17809A08fd005);


    
    string public name;
    string public symbol;
    address payable OwnerAddress;
    uint64 public TokenSupply;
    uint64 public eventStartDate;
    uint256 public TokenPrice;
    uint256 public initialTokenPrice;
    uint64 public transferFee;
    
    address authAddr ;
    
    constructor() public {
       a=new DoToken(name, symbol,  eventStartDate, TokenSupply, TokenPrice,  initialTokenPrice, transferFee);
       b=new DoAuth();
    }


    
    function AccessControl(string memory _login) public{
        authAddr = b.authAddress(_login);
        if (msg.sender == authAddr)
            b.createAccount(_login);
            return a;
        return a;
    }


}
