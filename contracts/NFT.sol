// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MonadDogeNFT is ERC721URIStorage, Ownable {
    uint256 public maxSupply;  
    uint256 public mintPrice; // 🔹 Now Editable (Removed `constant`)
    uint256 private _tokenIdCounter; 

    string private _baseTokenURI; 

    constructor(uint256 _maxSupply, uint256 _mintPrice, string memory baseURI_) 
        ERC721("MonadDoge", "MDOGE") Ownable(msg.sender) 
    {
        maxSupply = _maxSupply;  
        mintPrice = _mintPrice; // 🔹 Set initial mint price
        _baseTokenURI = baseURI_; 
        _tokenIdCounter = 0; 
    }

    // 🔹 Owner can change max supply (only if current supply is less)
    function setMaxSupply(uint256 newMaxSupply) public onlyOwner {
        require(newMaxSupply >= _tokenIdCounter, "Cannot set max supply below minted NFTs");
        maxSupply = newMaxSupply;
    }

    // 🔹 Owner can update mint price after deployment
    function setMintPrice(uint256 newPrice) public onlyOwner {
        require(newPrice > 0, "Mint price must be greater than zero");
        mintPrice = newPrice;
    }

    // 🔹 Owner can update Base URI
    function setBaseURI(string memory newBaseURI) public onlyOwner {
        _baseTokenURI = newBaseURI;
    }

    // 🔹 Override OpenZeppelin `_baseURI()`
    function _baseURI() internal view override returns (string memory) {
        return _baseTokenURI;
    }

    // 🔹 Public Minting (Supports Multiple Minting)
    function mintNFT(uint256 quantity) public payable {
        require(quantity > 0, "Must mint at least 1 NFT");
        require(_tokenIdCounter + quantity <= maxSupply, "Exceeds max supply");
        require(msg.value >= mintPrice * quantity, "Insufficient funds");

        for (uint256 i = 0; i < quantity; i++) {
            uint256 newTokenId = _tokenIdCounter;
            _safeMint(msg.sender, newTokenId);
            _setTokenURI(newTokenId, string(abi.encodePacked(_baseTokenURI, uint2str(newTokenId), ".json")));

            _tokenIdCounter++; 
        }

        // 🔹 Send mint fee directly to contract owner
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
