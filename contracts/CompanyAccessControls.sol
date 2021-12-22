pragma solidity ^0.4.24;

contract CompanyAccessControls {
    
    address[3] private cSuiteAddresses;
    bool[3] private cSuiteAck;
    
    enum cSuite {
        CEO,
        CTO,
        CFO
    }
    
    constructor() public {
        cSuiteAddresses[uint8(cSuite.CEO)] = msg.sender;
        cSuiteAddresses[uint8(cSuite.CTO)] = msg.sender;
        cSuiteAddresses[uint8(cSuite.CFO)] = msg.sender;
    }
    
    modifier onlyCpositionO (cSuite position){
        require(msg.sender == cSuiteAddresses[uint8(position)]);
        _;
    }
    
    modifier onlyCSuite(){
        require(msg.sender == cSuiteAddresses[uint8(cSuite.CEO)] ||
                msg.sender == cSuiteAddresses[uint8(cSuite.CTO)] ||
                msg.sender == cSuiteAddresses[uint8(cSuite.CFO)]);
        _;
    }
    
    modifier onlyCEOorCFO() {
        require(msg.sender == cSuiteAddresses[uint8(cSuite.CEO)] ||
                msg.sender == cSuiteAddresses[uint8(cSuite.CFO)]);
        require(cSuiteAck[uint8(cSuite.CFO)] && cSuiteAck[uint8(cSuite.CEO)]);
        cSuiteAck[uint8(cSuite.CFO)] = false;
        cSuiteAck[uint8(cSuite.CEO)] = false;
        _;
    }

    modifier onlyCEOorCTO() {
        require(msg.sender == cSuiteAddresses[uint8(cSuite.CEO)] ||
                msg.sender == cSuiteAddresses[uint8(cSuite.CTO)]);
        require(cSuiteAck[uint8(cSuite.CTO)] && cSuiteAck[uint8(cSuite.CEO)]);
        cSuiteAck[uint8(cSuite.CEO)] = false;
        cSuiteAck[uint8(cSuite.CTO)] = false;
        _;
    }
    
    modifier onlyCSuiteAck(){
        require(cSuiteAck[uint8(cSuite.CEO)] &&
                cSuiteAck[uint8(cSuite.CTO)] &&
                cSuiteAck[uint8(cSuite.CFO)]);
        cSuiteAck[uint8(cSuite.CEO)] = false;
        cSuiteAck[uint8(cSuite.CTO)] = false;
        cSuiteAck[uint8(cSuite.CFO)] = false;
        _;
    }
    
    function getAddress(cSuite position) public view onlyCSuite returns (address) {
        return cSuiteAddresses[uint8(position)];
    }
    
    function isAcknowledged(cSuite position) public view returns (bool){
        return cSuiteAck[uint8(position)];
    }
    
    function Acknowledge(cSuite position) public onlyCpositionO(position) {
        cSuiteAck[uint8(position)] = true;
    }
    
    function newCPositionAddress (cSuite position, address _newAddress) public onlyCSuite onlyCSuiteAck {
        require(_newAddress != address(0));
        cSuiteAddresses[uint8(position)] = _newAddress;
    } 
}