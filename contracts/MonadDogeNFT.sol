// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MonadDogeNFT is ERC721URIStorage, Ownable {
    uint256 public maxSupply;  // Owner can set max supply
    uint256 public mintPrice = 1 ether; // Default mint price (1 MON)
    uint256 private _tokenIdCounter = 0; // NFT ID tracker
    string public baseURI = "https://gateway.pinata.cloud/ipfs/bafybeig7ckgnpsqefislvfye7gqmoun46w76a355tdxbmmlgms4bl25dsy/";

    constructor(uint256 _maxSupply) ERC721("MonadDoge", "MDOGE") Ownable(msg.sender) {
        maxSupply = _maxSupply;  // Owner sets supply at deployment
    }

    // 🔹 Owner can change max supply (only if current supply is less)
    function setMaxSupply(uint256 newMaxSupply) public onlyOwner {
        require(newMaxSupply >= _tokenIdCounter, "Cannot set max supply below minted NFTs");
        maxSupply = newMaxSupply;
    }

    // 🔹 Owner can change mint price
    function setMintPrice(uint256 newPrice) public onlyOwner {
        mintPrice = newPrice;
    }

    // 🔹 Owner can update Base URI (if needed)
    function setBaseURI(string memory newBaseURI) public onlyOwner {
        baseURI = newBaseURI;
    }

    // 🔹 Mint Multiple NFTs (User can specify quantity)
    function mintNFT(uint256 quantity) public payable {
        require(quantity > 0, "Must mint at least 1 NFT");
        require(_tokenIdCounter + quantity <= maxSupply, "Exceeds max supply");
        require(msg.value >= mintPrice * quantity, "Insufficient funds");

        for (uint256 i = 0; i < quantity; i++) {
            uint256 newTokenId = _tokenIdCounter;
            _tokenIdCounter++;

            string memory tokenURI = string(abi.encodePacked(baseURI, uint2str(newTokenId), ".json"));

            _safeMint(msg.sender, newTokenId); // Transfer NFT to minter
            _setTokenURI(newTokenId, tokenURI);
        }

        // 🔹 Automatically send mint fee to owner
        payable(owner()).transfer(msg.value);
    }

    // 🔹 Helper function to convert uint to string
    function uint2str(uint256 _i) internal pure returns (string memory) {
        if (_i == 0) {
            return "0";
        }
        uint256 j = _i;
        uint256 length;
        while (j != 0) {
            length++;
            j /= 10;
        }
        bytes memory bstr = new bytes(length);
        uint256 k = length;
        j = _i;
        while (j != 0) {
            bstr[--k] = bytes1(uint8(48 + j % 10));
            j /= 10;
        }
        return string(bstr);
    }
}
