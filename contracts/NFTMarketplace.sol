//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "hardhat/console.sol";
//OpenZeppelin's NFT Standard Contracts. We will extend functions from this in our implementation
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
contract NFTMarketplace is ERC721URIStorage {
    //constructor sets up our owner 
    constructor() ERC721("NFTMarketplace" , "NFTM") {
        owner = payable(msg.sender);
    }

    //Importing Counters from counter.sol to give each newly minted nft a new ID
    using Counters for Counters.Counter;

    // _tokenIds variable has the most recent minted tokenId
    Counters.Counter private _tokenIds;

    //Keeps track of the number of items sold on the marketplace
    Counters.Counter private _itemsSold;

    //owner is the contract address that created the smart contract
    address payable owner;

    //The mandatory fee to be paid while listing an NFT
    uint256 listPrice = 0.01 ether;

    //The structure tp store info about a listed token 
    struct ListedNFT {
        uint256 tokenId;
        address payable owner;
        address payable seller;
        uint256 price;
        bool currentlyListed;
    }

    //the event emmited when a token is successfully listed
    event TokenListedSuccess(
        uint256 indexed tokenId,
        address owner,
        address seller,
        uint256 price,
        bool currentlyListed
    );

    /*This mapping maps tokenId to token info and is helpful
    while requesting info about an NFT by ID*/
    mapping(uint256 => ListedNFT) private idToListedToken;
    //The first time a token is created  , it is listed here

    function createToken(string memory tokenURI, uint256 price) public payable returns(uint){
     //Make sure the sender sent through sent enough ETH to pay for listing
    require(msg.value == listPrice, "Please make sure ypou have enough funds");
    
    //Make sure u list NFT for a positive amount
    require(price >0 ,"Input  positive amount man , do u want to pay gas and get nothing?");
    
    /*We first increment the tokenId counter , which is keeping track
    of the number of minted NFTs*/

    _tokenIds.increment(); /* increment is built in function inside counters.sol 
    which prevents overflow , if any*/

    uint newTokenId = _tokenIds.current(); /*current(); is also a built in ,
    which returns the current counter number*/

    /*Mint the NFT  with tokenId = newTokenId to the address who 
    called the createToken function */
    _safeMint(msg.sender , tokenURI); /* calling the openzeppelin audited
    code*/

    //Map the tokenId to the tokenURI (which is an IPFS URl with the metadata)
    _setTokenURI(newTokenId,price);

    //Helper function to update Global variables and emit an event
    createListedToken(newTokenId, price);

    return newTokenId;
}

function createListedToken(uint256 tokenId,uint256 price) private {
    /*Update the mapping of tokenId's to Token details ,useful for 
    retrieval functions */

    idToListedToken[tokenId] = ListedNFT(
        tokenId,
        payable(address(this)),
        payable(msg.sender),
        price,
        true
    );

// from msg.sender , to , address(this) 
    _transfer(msg.sender , address(this), tokenId);
    /*Emit the event for successful transfer. The frontend parses 
    this message and updates  the end user */

    emit TokenListedSuccess(
        tokenId,
        address(this),
        msg.sender,
        price,
        true
    );
}


/* helper function section*/
//In case owner of marketplace wants to change NFT listing fee in future
function updateListPrice(uint256 _listPrice) public payable {
    require(msg.sender == owner ,"You cannot change the price man");
    listPrice = _listPrice;
}

//Fetch Current Listing Fee of an NFT on the marketplace
function getListPrice () public view returns (uint256) {
    return listPrice;
}

//Fetch the Data for the latest NFt that was listed
function getLatestIdToListedNFT() public view returns(ListedNFT memory) {
    uint256 currentTokenId = _tokenIds.current();
    return idToListedToken(currentTokenId);
}

//Fetch the latest NFT's serial number
function getListedForTokenId(uint256 tokenId) public view returns(ListedNFT memory) {
    return _tokenIds.current();
}

function getAllNFTs() public view returns(ListedNFT[] memory) {
    uint nftCount = _tokenIds.current();
    /* the standard way of creating a static array is
    NameOfArray[](CountOfElements) , 
    replace with 
    Array name and length you want*/
    uint currentIndex = 0;

    /* declaring a new array named tokens in which all the listed 
    NFTs will be added when called*/
    ListedNFT[] memory tokens = new ListedNFT[](nftCount);
    for (uint i = 0 ; i <nftCount ; i++){

        /* remember , the mapping object stores the counter as 1,2,3,4
        and so on , that is why we need to set the map key value as 
        one greater than the current index*/
        uint currentId = i+1;
        /*assigning the first key value of the idToListedToken mapping
        object a value*/ 
        ListedNFT[] storage currentItem = idToListedToken[currentId];
        /*setting the above value on 0th index in the tokens array
        and so on*/
        tokens[currentIndex] = currentItem;
        /*increasing the index for the nect call*/
        currentIndex += 1;
    }
    return tokens;
}

function getMyNFts() public view returns(ListedNFT[] memory) {
    uint totalItemCount = _tokenIds.current();
    uint itemCount = 0;
    uint currentIndex = 0;

    /* Imprtant to get a count of all the nfts owned by msg.sender 
    before we can make an array for them */
    for(uint i =0 ; i< totalItemCount ; i++){
        if(idToListedToken[i+1].owner == msg.sender || idToListedToken[i+1].seller == msg.sender){
            /* getting the count of NFTs the address ever had*/
            itemCount +=1;
        } 
    }
    /*now that ww have a count of NFTS for that person */
    ListedNFT[] memory items = new ListedNFT[](itemCount);
    for  (uint i =0 ;i<totalItemCount;i++){
        if(idToListedToken[i+1].owner == msg.sender || idToListedToken[i+1].seller = msg.sender ) {
            
        }
    }
}

function executeSale() public {

}
}