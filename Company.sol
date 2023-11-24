// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DataMarketplace {
    event CompanyRegistered(address indexed company, string companyName, string email);
    event DataPurchased(address indexed buyer, address indexed seller, string data, uint256 price, string dataTopic);

    struct Company {
        string companyName;
        string email;
        bool isRegistered;
        string chosenDataTopic;
    }

    struct Data {
        address user;
        string data;
        uint256 price;
        bool isForSale;
        string dataTopic;
    }

    mapping(address => Company) public companies;
    mapping(uint256 => Data) public data;
    uint256 public dataCount;

    modifier companyNotRegistered() {
        require(!companies[msg.sender].isRegistered, "Company is already registered");
        _;
    }

    modifier companyRegistered() {
        require(companies[msg.sender].isRegistered, "Company is not registered");
        _;
    }

    constructor() {}

    function registerCompany(string memory _companyName, string memory _email) external companyNotRegistered {
        companies[msg.sender] = Company(_companyName, _email, true, "");
        emit CompanyRegistered(msg.sender, _companyName, _email);
    }

    function chooseDataTopic(string memory _dataTopic) external companyRegistered {
        companies[msg.sender].chosenDataTopic = _dataTopic;
    }

  function postData() external view companyRegistered {
    require(false, "Companies are not allowed to post data");
}


    function purchaseAllData() external companyRegistered {
        require(bytes(companies[msg.sender].chosenDataTopic).length > 0, "No data topic chosen");

        // Iterate through all data to find matching topics
        for (uint256 i = 0; i < dataCount; i++) {
            Data storage dataItem = data[i];
            if (dataItem.isForSale && keccak256(bytes(dataItem.dataTopic)) == keccak256(bytes(companies[msg.sender].chosenDataTopic))) {
                // Transfer funds to the data owner
                address payable seller = payable(dataItem.user);
                seller.transfer(dataItem.price);

                // Update data state
                dataItem.isForSale = false;

                // Emit event
                emit DataPurchased(msg.sender, dataItem.user, dataItem.data, dataItem.price, dataItem.dataTopic);
            }
        }
    }
}
