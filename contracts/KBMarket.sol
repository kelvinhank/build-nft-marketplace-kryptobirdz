//SPDX-License-Identifier:MIT
pragma solidity ^0.8.4;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";

contract KBMarket is ReentrancyGuard {
    using Counters for Counters.Counter;
    Counters.Counter public _tokenId;
    Counters.Counter public _tokensSold;
    address  payable public owner;
    uint256 listingPrice = 0.045 ether;

    constructor() {
        owner = payable(msg.sender);
    }

    struct MarketToken {
        uint256 itemId;
        address nftContract;
        uint256 tokenId;
        address payable seller;
        address payable owner;
        uint256 price;
        bool sold;
    }
    mapping(uint256 => MarketToken) public idToMarketToken;
    event MarketTokenMinted(
        uint256 indexed itemId,
        address indexed nftContract,
        uint256 indexed tokenId,
        address payable seller,
        address payable owner,
        uint256 price,
        bool sold
    );
    
    function getListingPrice() public view returns (uint256) {
        return listingPrice;
    }

    //mint a marketItem up sale
    function makeMarketItem(
        address nftContract,
        uint256 tokenId,
        uint256 price
    ) public payable nonReentrant {
        require(price > 0, "Price must be at least one wei");
        require(
            msg.value == listingPrice,
            "Price must be equal to listing price"
        );
        _tokenId.increment();
        uint256 itemId = _tokenId.current();
        idToMarketToken[itemId] = MarketToken(
            itemId,
            nftContract,
            tokenId,
            payable(msg.sender),
            payable(address(0)),
            price,
            false
        );
        IERC721(nftContract).transferFrom(msg.sender, address(this), tokenId);
        emit MarketTokenMinted(
            itemId,
            nftContract,
            tokenId,
            payable(msg.sender),
            payable(address(0)),
            price,
            false
        );
    }

    //buy
    function createMarketSale(address nftContract, uint256 itemId)
        public
        payable
        nonReentrant
    {
        uint256 price = idToMarketToken[itemId].price;
        uint256 tokenId = idToMarketToken[itemId].tokenId;
        require(
            msg.value == price,
            "Please submit the asking price in order to continue"
        );
        idToMarketToken[itemId].seller.transfer(msg.value);
        IERC721(nftContract).transferFrom(address(this), msg.sender, tokenId);
        idToMarketToken[itemId].owner = payable(msg.sender);
        idToMarketToken[itemId].sold = true;
        _tokensSold.increment();
        payable(owner).transfer(listingPrice);
    }

    //get list token unsold
    function fetchMarketToken() public view returns (MarketToken[] memory) {
        uint256 itemCount = _tokenId.current();
        uint256 unSoldItemCount = itemCount - _tokensSold.current();
        uint256 currentIndex = 0;
        MarketToken[] memory items = new MarketToken[](unSoldItemCount);
        for (uint256 i = 0; i < itemCount; i++) {
            if (idToMarketToken[i + 1].owner == address(0)) {
                MarketToken memory   currentItem = idToMarketToken[i + 1];
                items[currentIndex] = currentItem;
                currentIndex++;
            }
        }
        return items;
    }

    //get my nft
    function fetchMyNFTs() public view returns (MarketToken[] memory) {
        uint256 itemCount = _tokenId.current();
        uint256 count = 0;
        uint256 currentIndex = 0;
        for (uint256 i = 0; i < itemCount; i++) {
            if (idToMarketToken[i + 1].owner == msg.sender) {
                count++;
            }
        }
        MarketToken[] memory items = new MarketToken[](count);
        for (uint256 i = 0; i < itemCount; i++) {
            if (idToMarketToken[i + 1].owner == msg.sender) {
                MarketToken memory currentItem = idToMarketToken[i+1];
                items[currentIndex]=currentItem;
                currentIndex++;
            }
        }
        return items;
    }
    //get my item created by my self
    function fetchItemsCreated() public view returns(MarketToken[] memory){
    uint256 itemCount = _tokenId.current();
        uint256 count = 0;
        uint256 currentIndex = 0;
        for (uint256 i = 0; i < itemCount; i++) {
            if (idToMarketToken[i + 1].seller == msg.sender) {
                count++;
            }
        }
        MarketToken[] memory items = new MarketToken[](count);
        for (uint256 i = 0; i < itemCount; i++) {
            if (idToMarketToken[i + 1].seller == msg.sender) {
                MarketToken memory currentItem = idToMarketToken[i+1];
                items[currentIndex]=currentItem;
                currentIndex++;
            }
        }
        return items;     
    }
}
