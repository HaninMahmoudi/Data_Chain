// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Users {
    uint256 public userCount;
    uint256 public dataCount;

    event UserRegistered(address indexed user, string pseudonym, string dataTopic);
    event DataPosted(address indexed user, string data, uint256 feesEarned, string dataTopic);

    struct User {
        string pseudonym;
        bool isRegistered;
        string dataTopic;
    }

    struct Data {
        address user;
        string data;
        uint256 price;
        bool isForSale;
        string dataTopic;
    }

    mapping(address => User) public users;
    mapping(uint256 => Data) public data;
    mapping(string => uint256[]) public topicToData;

    modifier userNotRegistered() {
        require(!users[msg.sender].isRegistered, "User is already registered");
        _;
    }

    modifier userRegistered() {
        require(users[msg.sender].isRegistered, "User is not registered");
        _;
    }

    constructor() {}

    function registerUser(string memory _pseudonym, string memory _dataTopic) external userNotRegistered {
        users[msg.sender] = User(_pseudonym, true, _dataTopic);
        emit UserRegistered(msg.sender, _pseudonym, _dataTopic);
        userCount++;
    }

    function chooseDataTopic(string memory _dataTopic) external userRegistered {
        users[msg.sender].dataTopic = _dataTopic;
    }

    function postData(string memory _data, uint256 _price) external userRegistered {
        require(bytes(_data).length > 0, "Data cannot be empty");
        uint256 feesEarned = calculateFees();
        data[dataCount] = Data(msg.sender, _data, _price, true, users[msg.sender].dataTopic);
        topicToData[users[msg.sender].dataTopic].push(dataCount);
        emit DataPosted(msg.sender, _data, feesEarned, users[msg.sender].dataTopic);
        dataCount++;
    }

    function calculateFees() internal pure returns (uint256) {
        // This is a simple example; you can implement a more complex logic for fee calculation.
        return 1 ether; // Fixed fee for simplicity; adjust as needed.
    }

    // New function to set the status of data for sale
    function setIsForSale(uint256 _dataId, bool _isForSale) external {
        require(data[_dataId].user == msg.sender, "You can only update your own data");
        data[_dataId].isForSale = _isForSale;
    }
}
