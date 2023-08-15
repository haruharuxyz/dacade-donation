// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

/// @title Donation Contract
/// @notice A contract for uploading images and accepting donations
/// @dev This contract allows users to upload images along with descriptions,
/// and other users can donate Ether to the image authors.
contract Donation {
    uint256 public imageCount;

      // Mapping to track whether an image hash has been uploaded
      mapping(string => bool) private uploadedImageHashes;
      address private contractOwner;

  // Modifier to check if the sender is the contract owner
    modifier onlyOwner() {
        require(msg.sender == contractOwner, "Only contract owner can perform this");
        _;
    }
    
    /// @dev Constructor to initialize the image count
    constructor() {
        imageCount = 0;
        contractOwner = msg.sender;

    }

    struct Image {
        uint256 id;
        string hash;
        string description;
        uint256 donationAmount;
        address payable author;
    }

    /// @notice Event emitted when a new image is uploaded
    event ImageCreated(
        uint256 id,
        string hash,
        string description,
        uint256 donationAmount,
        address author
    );

    /// @notice Event emitted when a donation is made to an image
    event DonateImage(
        uint256 id,
        string hash,
        string description,
        uint256 donationAmount,
        address author
    );

    /// @notice Upload an image along with its description
    /// @param _imgHash Hash of the image
    /// @param _description Description of the image
    function uploadImage(string memory _imgHash, string memory _description) public {
        require(bytes(_imgHash).length > 0, "Image hash cannot be empty");
        require(bytes(_description).length > 0, "Description cannot be empty");
        require(msg.sender != address(0), "Invalid sender address");
        require(!uploadedImageHashes[_imgHash], "Image already uploaded");

        uploadedImageHashes[_imgHash] = true;


        imageCount++;
        images[imageCount] = Image(
            imageCount,
            _imgHash,
            _description,
            0,
            payable(msg.sender)
        );
        emit ImageCreated(imageCount, _imgHash, _description, 0, msg.sender);
    }

       // Withdraw accidentally sent funds
    function withdrawAccidentalFunds() public onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No Ether to withdraw");

        payable(contractOwner).transfer(balance);
    }

    function withdrawDonations(uint256 _imageId) public {
    require(_imageId > 0 && _imageId <= imageCount, "Invalid image ID");

    Image storage _image = images[_imageId];
    require(msg.sender == _image.author, "Only the image author can withdraw");

    uint256 authorBalance = _image.donationAmount;
    require(authorBalance > 0, "No donations to withdraw");

    _image.donationAmount = 0; // Reset the author's balance
    images[_imageId] = _image;

    payable(msg.sender).transfer(authorBalance);
}


    /// @notice Donate Ether to the author of an image
    /// @param _id ID of the image to donate to
    function donateImageOwner(uint256 _id) public payable {
        require(_id > 0 && _id <= imageCount, "Invalid image ID");
        
        Image storage _image = images[_id]; // Use storage for direct modification
        address payable _author = _image.author;
        
        uint256 donationAmount = msg.value;
        require(donationAmount > 0, "Donation amount must be greater than 0");
        
        _image.donationAmount += donationAmount; // Update donation amount
        
        // Use "Checks-Effects-Interactions" pattern to mitigate reentrancy
        (bool success, ) = _author.call{value: donationAmount}("");
        require(success, "Donation transfer failed");
        
        emit DonateImage(
            _id,
            _image.hash,
            _image.description,
            _image.donationAmount,
            _author
        );
    }
    
    // Fallback function to handle accidental transfers
    receive() external payable {
        revert("Contract does not accept direct payments");
    }
    
    mapping(uint256 => Image) public images;
}
