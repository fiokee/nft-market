// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFTMarketplace is ERC721URIStorage, Ownable {
    uint256 public mintPrice = 0.01 ether;
    uint256 public totalSupply;
    mapping(uint256 => uint256) public nftPrices;
    mapping(uint256 => bool) public listedForSale;

    event NFTMinted(uint256 tokenId, address owner);
    event NFTListed(uint256 tokenId, uint256 price);
    event NFTSold(uint256 tokenId, address buyer, uint256 price);

    constructor() ERC721("NFTMarketplace", "NFTM") {}

    // Minting function
    function mintNFT(string memory tokenURI) public payable {
        require(msg.value == mintPrice, "Incorrect minting price");

        totalSupply += 1;
        uint256 newTokenId = totalSupply;

        _mint(msg.sender, newTokenId);
        _setTokenURI(newTokenId, tokenURI);

        emit NFTMinted(newTokenId, msg.sender);
    }

    // Listing an NFT for sale
    function listNFT(uint256 tokenId, uint256 price) public {
        require(ownerOf(tokenId) == msg.sender, "Not the owner");
        require(price > 0, "Price must be greater than zero");

        nftPrices[tokenId] = price;
        listedForSale[tokenId] = true;

        emit NFTListed(tokenId, price);
    }

    // Buy an NFT
    function buyNFT(uint256 tokenId) public payable {
        require(listedForSale[tokenId], "NFT not for sale");
        uint256 price = nftPrices[tokenId];
        require(msg.value == price, "Incorrect price");

        address seller = ownerOf(tokenId);

        _transfer(seller, msg.sender, tokenId);
        payable(seller).transfer(msg.value);

        listedForSale[tokenId] = false;

        emit NFTSold(tokenId, msg.sender, price);
    }

    // Only owner can update mint price
    function setMintPrice(uint256 newPrice) public onlyOwner {
        mintPrice = newPrice;
    }
}
