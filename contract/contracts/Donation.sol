// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

contract Donation {
    uint256 public imageCount =  0;

    struct Image {
        uint256 id;
        string hash;
        string description;
        uint256 donationAmount;
        address payable author;
    }

    Image[] public images;

    event ImageCreated(
        uint256 id,
        string hash,
        string description,
        uint256 donationAmount,
        address author
    );

    event DonateImage(
        uint256 id,
        string hash,
        string description,
        uint256 donationAmount,
        address author
    );

    // Create an Image
    function uploadImage(string memory _imgHash, string memory _description) public {
        require(bytes(_imgHash).length > 0, "Image hash is required");
        require(bytes(_description).length > 0, "Description is required");
        require(msg.sender != address(0), "Invalid Address");

        for (uint256 i = 0; i < images.length; i++) {
            require(keccak256(bytes(images[i].hash)) != keccak256(bytes(_imgHash)), "Image hash already exists");
        }


        imageCount++;
        images.push(Image(
            images.length,
            _imgHash,
            _description,
            0,
            payable(msg.sender)
        ));

        emit ImageCreated(images.length - 1, _imgHash, _description, 0, msg.sender);
    }

    function donateImageOwner(uint256 _id) public payable {
        require(_id > 0 && _id <= imageCount, "Invalid image ID");

        Image memory _image = images[_id];
        address payable _author = _image.author;
        address(_author).call{value: msg.value};
        _image.donationAmount = _image.donationAmount + msg.value;
        images[_id] = _image;

        emit DonateImage(
            _id,
            _image.hash,
            _image.description,
            _image.donationAmount,
            _author
        );
    }
}
