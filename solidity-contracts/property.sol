// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;


contract Registry {
    

    
    uint nProperties;
    

    struct PropertyInfo {
        uint price; 
        string location;
        uint size; 
        bool available;
        uint pid;
    }

    mapping(uint256 => PropertyInfo) properties;
    mapping (uint => address) public __ownedLands; 
    struct Purchase {
        uint pid;
        address buyer;
        address owner;
        uint price;
    }

    Purchase[] purchases;

 
    event NewPropertyEvent(
        uint id,
        address owner,
        uint price,
        string location,
        uint size
    );

    event BuyPropertyEvent(
        address buyer,
        uint pid,
        uint price
    );

    event PropertyAvailabilityEvent(
        uint pid,
        bool available
    );

    


    constructor() {
        nProperties =0;
        
    }

    
    function addProperty(
        uint _price,
        string memory _location,
        uint _size
    ) public {
      
        uint256 pid = nProperties;
        __ownedLands[pid]= msg.sender;
        nProperties++;
        
        
        // Store property metadata
        PropertyInfo memory prop = PropertyInfo(
            _price,
            _location,
            _size,
            true,  // Default availability
            nProperties-1
        );
        properties[pid] = prop;

        emit NewPropertyEvent(
            pid, 
            msg.sender,
            _price,
            _location,
            _size
        );
    }

    
    function ownerOf(uint pid) public view returns (address){
        return __ownedLands[pid];

    }
    function buyProperty (uint pid) public payable {
        address owner = __ownedLands[pid];

   
        require(
            properties[pid].available, 
            "Registry: Property not available for buying"
        );

        // Check if sufficient money was sent
        require(
            msg.value >= properties[pid].price,
            "Registry: Not enough money provided for buying"
        );

        // Update property status
        properties[pid].available = false;

        // Send money to owner
        (bool success, ) = address(owner).call{ value: msg.value }("");
        require(success, "Registry: Failed to send money to owner");

        __ownedLands[pid] = msg.sender;

        Purchase memory pur = Purchase(pid, msg.sender, owner, properties[pid].price);
        purchases.push(pur);

        emit BuyPropertyEvent(
            msg.sender,
            pid,
            properties[pid].price
        );
    }

    function getPurchases() public view returns (Purchase[] memory) {
        return purchases;
    }

    function getProperties() public view returns (PropertyInfo[] memory){
        PropertyInfo[] memory result = new PropertyInfo[](nProperties);

        for (uint i=0; i < nProperties; i++) {
            result[i] = properties[i];
        }

        return result;
    }


    function setPropertyAvailability (uint pid, bool avl) public {
        // Check if caller is owner
        require(
            __ownedLands[pid] == msg.sender,
            "Registry: Property not owned by caller"
        );

        properties[pid].available = avl;
        
        emit PropertyAvailabilityEvent(
            pid,
            avl
        );
    }

}