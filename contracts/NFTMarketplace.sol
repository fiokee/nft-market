// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract NFTMarketplace is ERC721, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    
    struct NFT {
        uint256 id;
        address owner;
        uint256 price;
        bool forSale;
    }
    
    mapping(uint256 => NFT) public nfts;

    constructor() ERC721("NFTMarketplace", "NFTM") {}

    // Mint a new NFT
    function mintNFT(string memory tokenURI) public onlyOwner returns (uint256) {
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _mint(msg.sender, newItemId);
        _setTokenURI(newItemId, tokenURI);
        
        nfts[newItemId] = NFT(newItemId, msg.sender, 0, false);
        return newItemId;
    }

    // List an NFT for sale
    function listNFT(uint256 tokenId, uint256 price) public {
        require(ownerOf(tokenId) == msg.sender, "Only the owner can list the NFT");
        nfts[tokenId].price = price;
        nfts[tokenId].forSale = true;
    }

    // Buy an NFT
    function buyNFT(uint256 tokenId) public payable {
        require(nfts[tokenId].forSale, "This NFT is not for sale");
        require(msg.value == nfts[tokenId].price, "Incorrect price");

        address owner = ownerOf(tokenId);
        payable(owner).transfer(msg.value);
        _transfer(owner, msg.sender, tokenId);

        nfts[tokenId].owner = msg.sender;
        nfts[tokenId].forSale = false;
    }

    // Transfer ownership
    function transferNFT(uint256 tokenId, address newOwner) public {
        require(ownerOf(tokenId) == msg.sender, "Only the owner can transfer");
        _transfer(msg.sender, newOwner, tokenId);
        nfts[tokenId].owner = newOwner;
    }
}
