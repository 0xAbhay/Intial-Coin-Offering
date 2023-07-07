// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;


  import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
  import "@openzeppelin/contracts/access/Ownable.sol";
  import "./Itoken.sol";

  contract ICT is ERC20, Ownable{
    // price of one ICT token 

    uint256 public constant tokenPrice = 0.001 ether;

    // Each NFT would give the user 10 tokens
      // It needs to be represented as 10 * (10 ** 18) as ERC20 tokens are represented by the smallest denomination possible for the token
      // By default, ERC20 tokens have the smallest denomination of 10^(-18). This means, having a balance of (1)
      // is actually equal to (10 ^ -18) tokens.
      // Owning 1 full token is equivalent to owning (10^18) tokens when you account for the decimal places.
      // More information on this can be found in the Freshman Track Cryptocurrency tutorial.

    uint256 public constant tokensPerNFT = 10 * 10**18;

    // the max total supply is 5000 for ICT 
    uint256 public constant maxTotalSupply = 5000 * 10**8;

    //cryptodevContract instance
    Itoken NFTee;

    // mapping to keep track of which token id is claimed
    mapping (uint256=> bool) public tokenIdsClaimed;

    constructor(address _crytodevsContract) ERC20("initial coin Token", 'ICT'){
        NFTee = Itoken(_crytodevsContract);
    }

    // function for normal user to mint coin
    function mint(uint256 amount) public payable {
        uint256 _requiredAmount  = tokenPrice * amount;
        require(msg.value >= _requiredAmount, "Insufficient balance");

        uint256 amountDecimal = amount * 10**18;

        require(totalSupply() + amountDecimal <= maxTotalSupply,"total supply has been reached!");

        _mint(msg.sender,amountDecimal);

    }

// function for NFT holders

function claim() public{
    address sender  = msg.sender;

    // get the number of cdNFt held by a given sender address

    uint256 balance = NFTee.balanceOf(sender);

    // if the balcne is zero 
    require(balance > 0, "You dont own any Crypto devs NFT!");

    // amount keeps track of number of unclaimed tokenIds
    uint256 amount  = 0;

    //loop over the balance and get the token ID owned by `sender` at a given `index` of its token list.

    for( uint256 i = 0; i<balance; i++){
        uint256 tokenId  = NFTee.tokenOfOwnerByIndex(sender,i);

         // if the tokenID is not claimed the claim increase amount

         if(!tokenIdsClaimed[tokenId]){
            amount += 1;
         tokenIdsClaimed[tokenId] = true;
         }
    }

      // if  all the token ids have been claimed there ICT
    require(amount > 0,"You have Already claimed all your IC tokens" );

    _mint(msg.sender, amount * tokensPerNFT);
}

  

          function withdraw() public onlyOwner {
        uint256 amount = address(this).balance;
        require(amount > 0, "Nothing to withdraw, contract balance empty");
        
        address _owner = owner();
        (bool sent, ) = _owner.call{value: amount}("");
        require(sent, "Failed to send Ether");
      }

      // Function to receive Ether. msg.data must be empty
      receive() external payable {}

      // Fallback function is called when msg.data is not empty
      fallback() external payable {}
  }
