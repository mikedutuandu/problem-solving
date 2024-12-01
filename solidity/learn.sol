// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

interface Human {
    //Functions of an interface can be only of type external.
    function eat(string memory food) external pure returns (string memory);
}

contract Manager {
    uint constant FUND_AMOUNT = 1000;

    function getFund() public pure returns (uint){
        return FUND_AMOUNT;
    }
}

contract Car {
    address public owner;
    string public model;
    address public carAddr;

    constructor(address _owner, string memory _model) payable {
        owner = _owner;
        model = _model;
        carAddr = address(this);
    }
}

contract Owner {
    address owner;
    constructor(){
        owner = msg.sender;
    }

    function getOwnerVal() public view returns (address){
        return owner;
    }

    modifier onlyOwner {
        require(owner == msg.sender);
        _;
    }

    modifier cost(uint price) {
        if (msg.value >= price) {
            _;
        }
    }


    modifier onlyAfter(uint _time) {
        require(
            block.timestamp >= _time,
            "Function called too early."
        );
        _;
    }

}

contract MTest is Owner {

    enum Size{
        SMALL,
        LARGE
    }

    struct Book {
        string name;
        uint book_id;
    }

    event Log(address sender, string message);

    uint256 number;

    Size size;

    Size[] trackingSetSize;

    mapping(address => uint) balances;

    Book book;

    uint public creationTime = block.timestamp;

    Car[] public cars;

    constructor(uint256 n) {
        number = n;
    }

    function store(uint256 num) public {
        number = num;
    }

    function retrieve() public view returns (uint256){
        return number;
    }

    function setSmall() public {
        size = Size.SMALL;
        trackingSetSize.push(size);
    }

    function setlarge() public {
        size = Size.LARGE;
        trackingSetSize.push(size);
    }

    function setSize(Size s) public {
        size = s;
        trackingSetSize.push(size);
    }

    function getSize() public view returns (Size){
        return size;
    }

    function getTracking() public view returns (Size[] memory){
        return trackingSetSize;
    }

    function setMap(address _add, uint _val) public {
        balances[_add] = _val;
    }

    function getMap(address _add) public view returns (uint){
        return balances[_add];
    }


    function deleteMap(address _add) public {
        delete balances[_add];
    }

    function setBook() public onlyAfter(creationTime + 5 seconds) {
        book = Book("change your mind", 1);
        emit Log(msg.sender, "call setBook");
    }

    function getBookID() public view onlyOwner returns (uint){
        return book.book_id;
    }

    function getBookName() public view onlyOwner returns (string memory){
        return book.name;
    }

    // Function to deposit Ether into this contract.
    // Call this function along with some Ether.
    // The balance of this contract will be automatically updated.
    function deposit() public payable {}

    // Function to withdraw all Ether from this contract.
    function withdraw() public {
        // get the amount of Ether stored in this contract
        uint256 amount = address(this).balance;

        // send all Ether to owner
        (bool success,) = owner.call{value: amount}("");
        require(success, "Failed to send Ether");
    }


    function testRequire(uint i) public pure {
        require(i > 10, "Must greater than 10");
    }

    function testRevert(uint i) public pure {
        if (i < 10) {
            revert("Must greater than 10");
        }
    }

    function eat(string memory food) external pure returns (string memory){
        return food;
    }

    // call a contract that already is deployed
    function getFundFromManager(address add) public pure returns (uint) {
        Manager abc = Manager(add);
        return abc.getFund();
    }

    //Contract that Creates other Contracts by new keyword
    function createCar(address _owner, string memory _model) public {
        Car car = new Car(_owner, _model);
        cars.push(car);
    }

    function getCar(uint256 _index)
    public
    view
    returns (
        address,
        string memory,
        address,
        uint256
    )
    {
        Car car = cars[_index];

        return (car.owner(), car.model(), car.carAddr(), address(car).balance);
    }


}