// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract LearnopolyCertificate is ERC721URIStorage, Ownable {
    uint256 private _tokenIdCounter;

  
    mapping(address => mapping(string => bool)) public courseCompletion;

    /// @notice Constructor that sets the initial owner and initializes the token
    /// @param initialOwner The wallet address to set as the initial owner
    constructor(address initialOwner) ERC721("LearnopolyCertificate", "LNC") Ownable(initialOwner) {
        _tokenIdCounter = 1; // Initialize the token ID counter
    }

    /// @notice Mark a course as completed for a user
    /// @param user The user's address
    /// @param courseId The course ID
    function completeCourse(address user, string memory courseId) external onlyOwner {
        require(!courseCompletion[user][courseId], "Course already completed!");
        courseCompletion[user][courseId] = true;
    }

    /// @notice Issue a certificate NFT to a wallet address
    /// @param recipient The wallet address to receive the NFT
    /// @param courseId The course ID the certificate is for
    /// @param tokenURI The metadata URI for the NFT
    function issueCertificate(address recipient, string memory courseId, string memory tokenURI) external onlyOwner {
        require(courseCompletion[recipient][courseId], "Course not completed!");
        
        uint256 tokenId = _tokenIdCounter; // Get the current token ID
        _tokenIdCounter++; // Increment the token ID counter

        // Mint the NFT and set its metadata URI
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
