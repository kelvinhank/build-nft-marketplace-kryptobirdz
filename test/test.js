require("@nomiclabs/hardhat-ethers");
const { ethers } = require("hardhat");
describe("KBMarket", function () {
  it("Should mint and trade NFTs", async function () {
    //test to receive contract
    const Market = await ethers.getContractFactory("KBMarket");
    const market = await Market.deploy();
    await market.deployed();
    const marketAddress = market.address;
    console.log("marketAddress", marketAddress);
    const NFT = await ethers.getContractFactory("NFT");
    const nft = await NFT.deploy(marketAddress);
    await nft.deployed();
    const nftAddress = nft.address;
    console.log("nftAddress", nftAddress);
    //       //test to receive listing price and auction price
    let listingPrice = await market.getListingPrice();
    listingPrice = listingPrice.toString();
    console.log("listingPrice", listingPrice);
    const auctionPrice = ethers.utils.parseUnits("100", "ether");
    console.log("auctionPrice", auctionPrice);
    //       //test for minting
    await nft.mintToken("https-t1");
    await nft.mintToken("https-t2");
    await market.makeMarketItem(nftAddress, 1, auctionPrice, {
      value: listingPrice,
    });
    await market.makeMarketItem(nftAddress, 2, auctionPrice, {
      value: listingPrice,
    });

    const [_, buyerAddress] = await ethers.getSigners();
    // console.log(_);
    // console.log("buyerAddress",buyerAddress);
    await market.connect(buyerAddress).createMarketSale(nftAddress, 1, {
      value: auctionPrice,
    });
    let items = await market.fetchMarketToken();
    items = await Promise.all(
      items.map(async (i) => {
        const tokenUri = await nft.tokenURI(i.tokenId);
        console.log(tokenUri);
        let item = {
          itemId: i.itemId.toString(),
          tokenId: i.tokenId.toString(),
          seller: i.seller,
          owner: i.owner,
          price: i.price.toString(),
          sold: i.sold,
        };
        return item;
      })
    );
    // console.log("items",items);
    // console.log("total nft",await nft._tokenIds());
    // console.log("total nft market",await market._tokenId());
    // console.log("total nft market sold",await market._tokensSold());

    // console.log("info token",Market.idToMarketToken[(1)]);
    // console.log("info token",Market.idToMarketToken([2]));
    const owner = await market.owner()
    console.log("owner",owner);
    
  });
});
