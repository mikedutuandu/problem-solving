contract Base {
    address public owner;
    bool private locked;

    constructor() {
        owner = msg.sender;
    }

    modifier isOwner() {
        require(msg.sender == owner, "not owner");
        _;
    }

    modifier noReentrancy() {
        require(!locked, "locked");
        locked = true;
        _;
        locked = false;
    }
}