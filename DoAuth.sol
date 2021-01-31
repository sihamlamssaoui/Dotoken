pragma solidity ^0.5.5;

contract DoAuth {
	mapping (string => address) authAddr ;
	mapping (string => address) recoveryAddr ;

	event Create(string login);
	event AuthChange(string login, address from, address to);
	event RecoveryChange(string login, address from, address to);
	event Drop(string login, address by);
	
	function createAccount(string memory _login) public {
		require(bytes(_login).length <= 32);
		require(bytes(_login).length > 2);
		require(authAddr[_login] == address(0));
		authAddr[_login] = msg.sender;
		recoveryAddr[_login] = msg.sender;
		//emit Create(bytes32ToString(_login));
		emit Create(_login);
	}

	function authAddress(string memory _login) view public returns (address){
		return authAddr[_login];
	}

	function setAuthAddress(string memory _login, address _addr) public {
		require(authAddr[_login] == msg.sender || recoveryAddr[_login] == msg.sender);
		emit AuthChange(_login, authAddr[_login], _addr);
		authAddr[_login] = _addr;
	}

	function recoveryAddress(string memory _login) view public returns (address){
		return recoveryAddr[_login];
	}

	function setRecoveryAddress(string memory _login, address _addr) public {
		require(recoveryAddr[_login] == msg.sender);
		emit RecoveryChange(_login, authAddr[_login], _addr);
		recoveryAddr[_login] = _addr;
	}

	function dropAccount(string memory _login) public {
		require(recoveryAddr[_login] == msg.sender);
		delete authAddr[_login];
		delete recoveryAddr[_login];
		emit Drop(_login, msg.sender);
	}


}
