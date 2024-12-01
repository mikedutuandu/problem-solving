// SPDX-License-Identifier: GPL-3.0


/*
A. Flow sign a signature and verify it: https://solidity-by-example.org/signature/
### Creating sigHash and Signature (Frontend/Off-chain):
    1. Create the same hash that contract will create
    const messageHash = ethers.utils.solidityKeccak256(
        ['address', 'uint256'],
        [userAddress, amount]
    );

    2. Sign this hash with private key - this creates a unique signature
    const signature = await signer.signMessage(ethers.utils.arrayify(messageHash));


### Verifying in Contract (On-chain):
function withdraw(uint256 amount, bytes calldata signature) {
    // 1. Recreate the same hash
    bytes32 sigHash = keccak256(abi.encodePacked(msg.sender, amount));

    // 2. Verify signature - this recovers the signer's address from signature
    address recoveredSigner = ecrecover(sigHash, v, r, s);

    // 3. Check if recovered signer is the owner
    require(recoveredSigner == owner(), "Invalid signature");
}
The key points:

We're not comparing hash with signature
The signature is used to recover who signed the message
We verify if the recovered signer is the owner
ecrecover gets the address that created the signature

It's like:

Owner signs a message (creates signature)
Contract uses that signature to figure out who signed
Checks if that signer is the owner

B. The default variable visibility in Solidity is internal. The default function visibility in Solidity is public.

C. one ether is equal to 10^18 wei.

D. gas
- gas limit (max amount of gas you're willing to use for your transaction, set by you)
- gas price is how much ether you are willing to pay per gas
- Giả sử khi giao dịch, Gas Limit Ethereum là 21,000 và Gas Price là 106 Gwei. Như vậy:
  Gas Fee = 21,000 x 106 Gwei = 2,226,000 Gwei ~ 0,002226 ETH

E. In Solidity, there are three main data locations:

   + storage - permanent storage on blockchain (like a hard drive)
   + memory - temporary storage that lasts only during function execution (like RAM)
   + calldata - special read-only memory for function parameters

   + sample:
       function getTracking() public view returns(Size[] memory){
           return trackingSetSize;
       }
   + explain:
       So while the trackingSetSize array itself is stored in storage,
       when we return it in a function, we need to specify that we're returning a memory copy of that storage array.
       This is a requirement in Solidity for all reference types (arrays, structs, strings, etc.) in function returns.

F. initialize parent contract with parameters.

contract C is X, Y {
    // Pass the parameters here in the constructor,
    // similar to function modifiers.
    constructor(string memory _name, string memory _text) X(_name) Y(_text) {}
}

G. Immutable variables are like constants.
Values of immutable variables can be set inside the constructor but cannot be modified afterwards.

contract Immutable {
    // coding convention to uppercase constant variables
    address public immutable MY_ADDRESS;
    uint256 public immutable MY_UINT;

    constructor(uint256 _myUint) {
        MY_ADDRESS = msg.sender;
        MY_UINT = _myUint;
    }
}
*/



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