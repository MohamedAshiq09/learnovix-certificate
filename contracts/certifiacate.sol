// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract LearnopolyCertificate is ERC721URIStorage, Ownable {
    uint256 private _tokenIdCounter;

  
    mapping(address => mapping(string => bool)) public courseCompletion;


    constructor(address initialOwner) ERC721("LearnopolyCertificate", "LNC") Ownable(initialOwner) {
        _tokenIdCounter = 1; // Initialize the token ID counter
    }

    
    function completeCourse(address user, string memory courseId) external onlyOwner {
        require(!courseCompletion[user][courseId], "Course already completed!");
        courseCompletion[user][courseId] = true;
    }

    
    function issueCertificate(address recipient, string memory courseId, string memory tokenURI) external onlyOwner {
        require(courseCompletion[recipient][courseId], "Course not completed!");
        
        uint256 tokenId = _tokenIdCounter; 
        _tokenIdCounter++; 

       
        _safeMint(recipient, tokenId);
        _setTokenURI(tokenId, tokenURI);

        // Mark the course as completed and reset the mapping for reusability
        courseCompletion[recipient][courseId] = false;
    }

    /// @notice Get the total number of certificates issued
    /// @return The total certificates issued
    function totalCertificatesIssued() external view returns (uint256) {
        return _tokenIdCounter - 1; // Subtract 1 because counter starts at 1
    }

    /// @notice Directly mint and send an NFT to any specified wallet address
    /// @param to The wallet address to send the NFT
    /// @param tokenURI The metadata URI for the NFT
    function mintNFT(address to, string memory tokenURI) external onlyOwner {
        uint256 tokenId = _tokenIdCounter; // Get the current token ID
        _tokenIdCounter++; // Increment the token ID counter

        // Mint the NFT and set its metadata URI
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, tokenURI);
    }
}
