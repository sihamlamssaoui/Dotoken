pragma solidity ^0.5.5;


import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v2.4.0/contracts/token/ERC721/ERC721MetadataMintable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v2.4.0/contracts/token/ERC721/ERC721Burnable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v2.4.0/contracts/token/ERC721/ERC721Metadata.sol";


contract NFT is ERC721MetadataMintable, ERC721Burnable {







    string public name;
    string public symbol;
    address payable OwnerAddress;
    uint64 public TokenSupply;
    uint64 public eventStartDate;
    uint256 public TokenPrice;
    uint256 public initialTokenPrice;
    uint64 public transferFee;


  constructor(
	    string memory _name, 
	    string memory _symbol, 
	    uint64 _eventStartDate,
        uint64 _TokenSupply,
        uint256 _TokenPrice, 
        uint256 _initialTokenPrice,
        uint64 _transferFee ) ERC721Metadata(_name, _symbol) public {
        name = _name;
        symbol = _symbol;
        OwnerAddress = msg.sender;
        eventStartDate = uint64(_eventStartDate);
        TokenSupply = uint64(_TokenSupply);
        initialTokenPrice = uint256(_initialTokenPrice);
        TokenPrice = uint256(_TokenPrice);
        transferFee = uint64(_transferFee);
  }


  struct doToken  {
        uint256 price;
        bool forSale;
        bool used;
    }

  doToken[] doTokens;

    event doTokenCreation(address _by, uint256 _TokenId);
    event doTokenDestruction(address _by, uint256 _TokenId);
    event BalanceWithdrawn(address _by, address _to, uint256 _amount);

    modifier EventNotStarted() {
        require((uint64(now) < eventStartDate),"event has already started");
        _;
    }

    modifier isAvailable() {
        require((doTokens.length < TokenSupply),"no more new tickets available");
        _;
    }   


    modifier isNotUsed(uint256 _TokenId) {
        require(doTokens[_TokenId].used != true,"ticket already used");
        _;
    }

    modifier isTokenOwner(uint256 _TokenId) {
        require((ownerOf(_TokenId) == msg.sender),"no permission");
        _;
    }


    function setTokenToUsed(uint256 _TokenId) 
    public 
    isTokenOwner(_TokenId)
    {
        doTokens[_TokenId].used = true;
    }

    

    /** 
    * @dev set eventStartDate (global)
    */
    function setEventStartDate(uint64 _eventStartDate) 
    public 
    EventNotStarted 
    {
        eventStartDate = _eventStartDate;
    }


/* GETTERS */
    /** 
    * @dev Returns all the relevant information about a specific ticket
    */
    function getToken(uint256 _id) 
    external 
    view 
    returns (
        uint256 price, 
        bool forSale,
        bool used
    )
    {
        price = uint256(doTokens[_id].price);
        forSale = bool(doTokens[_id].forSale);
        used = bool(doTokens[_id].used);
    }

    /** 
    * @dev Returns the price of a specific ticket
    */
    function getTokenPrice(uint256 _TokenId) 
    public 
    view 
    returns (uint256) 
    {
        return doTokens[_TokenId].price;
    }

    
    /** 
    * @dev Returns the transfer fee of a specific Token
    */
    function getTokenTransferFee(uint256 _TokenId) 
    public 
    view 
    returns (uint256) 
    {
        return doTokens[_TokenId].price * transferFee;
    }

    /** 
    * @dev Returns the status of a specific Token
    */
    function getTokenStatus(uint256 _TokenId) 
    public 
    view 
    returns (bool) 
    {
        return doTokens[_TokenId].used;
    }

   
    /** 
    * @dev check ownership of ticket
    */
    function checkTokenOwnership(uint256 _TokenId) 
    external 
    view 
    returns (bool) 
    {
        require((ownerOf(_TokenId) == msg.sender),"no ownership of the given Token");
        return true;
    }

/* Additional functions */ 
    
    /** 
    * @dev create initial Token struct and generate ID (only ever called by BuyToken function)
    */
    function _createToken() 
    internal 
    EventNotStarted 
    isAvailable 
    returns (uint256) 
    {
            doToken memory _Token = doToken({
            price: initialTokenPrice,
            forSale: bool(false),
            used: bool(false)
        });
        uint256 newTokenId = doTokens.push(_Token) - 1;
        return newTokenId;
    }

    /** 
    * @dev mint a Token (primary market)
    */
    function buyToken() 
    external 
    payable 
    EventNotStarted 
    {   
        require((msg.value >= initialTokenPrice),"not enough money");
        
        if(msg.value > initialTokenPrice)
        {
            msg.sender.transfer(msg.value.sub(initialTokenPrice));
        }

        uint256 _TokenId = _createToken();
        _mint(msg.sender, _TokenId);
        emit doTokenCreation(msg.sender, _TokenId);
    }

    /** 
    * @dev approve a specific buyer of the Token to buy my Token
    */
    function approveAsBuyer(address _buyer, uint256 _TokenId) 
    public
    EventNotStarted  
    isTokenOwner(_TokenId)
    {
        approve(_buyer,_TokenId);
    }

    

    /** 
    * @dev burn a Token (if owner)
    */
    function destroyToken(uint256 _TokenId) 
    public 
    isTokenOwner(_TokenId) 
    {
        _burn(_TokenId);
        emit doTokenDestruction(msg.sender, _TokenId);
    }
    
    /** 
    * @dev withdraw money stored in this contract
    */
    function withdrawBalance() 
    public 
    {
        uint256 _contractBalance = uint256(address(this).balance);
        OwnerAddress.transfer(_contractBalance);
        emit BalanceWithdrawn(msg.sender,OwnerAddress,_contractBalance);
    }
}
