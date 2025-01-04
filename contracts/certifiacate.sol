// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract LearnopolyCertificate is ERC721URIStorage, Ownable {
    uint256 private _tokenIdCounter;

    struct Course {
        string courseId;
        string courseName;
        string description;
    }

 
    mapping(string => Course) public courses;

    mapping(address => mapping(string => bool)) public courseCompletion;

    event CourseCreated(string courseId, string courseName, string description);
    event CourseCompleted(address indexed user, string courseId);
    event CertificateIssued(address indexed user, uint256 tokenId, string courseId);
    event CertificateRevoked(address indexed user, uint256 tokenId);

    constructor(address initialOwner) ERC721("LearnopolyCertificate", "LNC") Ownable(initialOwner) {
        _tokenIdCounter = 1; 
    }

    function addCourse(string memory courseId, string memory courseName, string memory description) external onlyOwner {
        require(bytes(courses[courseId].courseId).length == 0, "Course ID already exists!");

        courses[courseId] = Course(courseId, courseName, description);
        emit CourseCreated(courseId, courseName, description);
    }

    function completeCourse(address user, string memory courseId) external onlyOwner {
        require(bytes(courses[courseId].courseId).length > 0, "Course does not exist!");
        require(!courseCompletion[user][courseId], "Course already completed!");

        courseCompletion[user][courseId] = true;
        emit CourseCompleted(user, courseId);
    }

    function issueCertificate(address recipient, string memory courseId, string memory tokenURI) public onlyOwner {
        require(courseCompletion[recipient][courseId], "Course not completed!");

        uint256 tokenId = _tokenIdCounter;
        _tokenIdCounter++;

        _safeMint(recipient, tokenId);
        _setTokenURI(tokenId, tokenURI);

        courseCompletion[recipient][courseId] = false;
        emit CertificateIssued(recipient, tokenId, courseId);
    }

    function revokeCertificate(uint256 tokenId) external onlyOwner {
        address owner = ownerOf(tokenId);

        _burn(tokenId);
        emit CertificateRevoked(owner, tokenId);
    }

    function batchIssueCertificates(address[] memory recipients, string memory courseId, string[] memory tokenURIs) external onlyOwner {
        require(recipients.length == tokenURIs.length, "Mismatched array lengths!");

        for (uint256 i = 0; i < recipients.length; i++) {
            issueCertificate(recipients[i], courseId, tokenURIs[i]);
        }
    }

    function totalCertificatesIssued() external view returns (uint256) {
        return _tokenIdCounter - 1;
    }

    function getCourseDetails(string memory courseId) external view returns (Course memory) {
        require(bytes(courses[courseId].courseId).length > 0, "Course does not exist!");
        return courses[courseId];
    }

    function isCourseCompleted(address user, string memory courseId) external view returns (bool) {
        return courseCompletion[user][courseId];
    }

    function mintNFT(address to, string memory tokenURI) external onlyOwner {
        uint256 tokenId = _tokenIdCounter;
        _tokenIdCounter++;

        _safeMint(to, tokenId);
        _setTokenURI(tokenId, tokenURI);
    }
}
