pragma solidity ^0.4.18;

contract EdAccessControl {

    address private ceoAddress;
    address private cfoAddress;
    address private ctoAddress;
    address private withdrawalAddress;

    bool ceoAcknowledged = false;
    bool cfoAcknowledged = false;
    bool ctoAcknowledged = false;

    event NewCEO(address oldCEO, address newCEO);
    event NewCFO(address oldCFO, address newCFO);
    event NewCTO(address oldCTO, address newCTO);


    constructor() public {
        ceoAddress = msg.sender;
        cfoAddress = msg.sender;
        ctoAddress = msg.sender;
    }

    modifier onlyCEO() {
        require(msg.sender == ceoAddress);
        _;
    }

    modifier onlyCFO() {
        require(msg.sender == cfoAddress);
        _;
    }

    modifier onlyCTO() {
        require(msg.sender == ctoAddress);
        _;
    }

    modifier onlyCEOorCFO() {
        require(msg.sender == ceoAddress ||
                msg.sender == cfoAddress);
        require(cfoAcknowledged && ceoAcknowledged);
        ceoAcknowledged = false;
        cfoAcknowledged = false;
        _;
    }

    modifier onlyCEOorCTO() {
        require(msg.sender == ceoAddress ||
                msg.sender == ctoAddress);
        require(ctoAcknowledged && ceoAcknowledged);
        ceoAcknowledged = false;
        ctoAcknowledged = false;
        _;
    }

    modifier onlyCSuite() {
        require(msg.sender == ceoAddress ||
                msg.sender == cfoAddress ||
                msg.sender == ctoAddress);
        _;
    }

    modifier onlyCSuiteAck(){
        require(ceoAcknowledged &&
                cfoAcknowledged &&
                ctoAcknowledged);
        cfoAcknowledged = false;
        ctoAcknowledged = false;
        ceoAcknowledged = false;
        _;
    }

    function chiefExecutiveOfficer() public view returns(address) {
        return ceoAddress;
    }

    function chiefFinOfficer() public view returns(address) {
        return cfoAddress;
    }

    function chiefTechOfficer() public view returns(address) {
        return ctoAddress;
    }

    function isCEOAcknowledged() onlyCSuite public view returns (bool){
        return ceoAcknowledged;
    }

    function isCFOAcknowledged() onlyCSuite public view returns (bool){
        return cfoAcknowledged;
    }

    function isCTOAcknowledged() onlyCSuite public view returns (bool){
        return ctoAcknowledged;
    }

    function ceoAcknowledge() onlyCEO public{
        ceoAcknowledged = true;
    }

    function cfoAcknowledge() onlyCFO public{
        cfoAcknowledged = true;
    }

    function ctoAcknowledge() onlyCTO public{
        ctoAcknowledged = true;
    }

    function newCEO(address newCEOAddress) onlyCSuite onlyCSuiteAck public{
        require(newCEOAddress != address(0));
        emit NewCEO(ceoAddress, newCEOAddress);
        ceoAddress = newCEOAddress;
    }

    function newCFO(address newCFOAddress) onlyCSuite onlyCSuiteAck public{
        require(newCFOAddress != address(0));
        emit NewCFO(cfoAddress, newCFOAddress);
        cfoAddress = newCFOAddress;
    }

    function newCTO(address newCTOAddress) onlyCSuite onlyCSuiteAck public{
        require(newCTOAddress != address(0));
        emit NewCTO(ctoAddress, newCTOAddress);
        ctoAddress = newCTOAddress;
    }
}
