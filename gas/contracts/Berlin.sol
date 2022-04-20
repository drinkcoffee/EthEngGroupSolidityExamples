// SPDX-License-Identifier: MIT
pragma solidity >=0.8 <0.9.0;

contract Berlin {
  uint256 public a1;
  uint256 public a2;
  uint256 public a3;

  address public addr;


  constructor() {
    a1 = 1;
  }

  function singleLoad() external {
    if (a1 == 2) {
      // Will never happen. Forces this to be a transaction function.
      a1 = 3;
    }
    dummy1();
  }
  function dummy1() internal {
    if (block.timestamp == 2) {
      // Will never happen. Forces this to be a transaction function.
      a1 = 3;
    }
  }



  function twoLoad() external {
    if (a1 == 2) {
      // Will never happen. Forces this to be a transaction function.
      a1 = 3;
    }
    dummy2();
  }
  function dummy2() internal {
    if (a1 == 3) {
      // Will never happen. Forces this to be a transaction function.
      a1 = 3;
    }
  }

  function prepForDel() external {
    a2 = 0;
    a3 = 1;
  }

  function del() external {
    a2 = 1;
    a3 = 0;
  }



  bytes public stuff;
  bytes32 public stuffHash;

  function setStuff(bytes calldata _stuff) external {
    stuff = _stuff;
  }

  function setStuffHash(bytes32 _stuffHash) external {
    stuffHash = _stuffHash;
  }

  struct Stuff {
    uint256 a;
    address b;
    bytes c;
  }
  Stuff public structStuff;

  function setStuffStruct(Stuff calldata _stuff) external {
    structStuff = _stuff;
    stuffHash = keccak256(abi.encode(_stuff));
  }


  uint256 public constant INVALID = 0x00;
  uint256 public val;

  function setVal(uint256 _val) external {
    require(_val != INVALID);
    val = _val;
  }

  function doStuffVal() external {
    require(val != INVALID);
    // ..do things.
  }





  function caching1(address _addr) external {
    require(addr != _addr);
    nothing();
    require(addr != msg.sender);
  }

  function caching2(address _addr) external {
    address addrStack = addr;
    require(addrStack != _addr);
    nothing();
    require(addrStack != msg.sender);
  }

  function nothing() public {

  }


  Berlin private other;

  function some() public {
    other.nothing{gas: 3000}();
  }


  mapping(address => uint256) public balance;
  mapping(address => bool) public blocked;

  function add(uint256 _amount) external {
    balance[msg.sender] += _amount;
  }

  function doIt() external {
    require(!blocked[msg.sender], "BLOCKED");
    require(balance[msg.sender] > 0, "SORRY");
  }

  modifier onlyAdmin {
    _;
  }

  mapping(address => bool) public authorised;

  function addUser(address _user) public onlyAdmin {
    authorised[_user] = true;
  }

  function doIt1() public {
    require(authorised[msg.sender], "Not Authorised");
  }


  function doIt2(uint256 _expiry, uint8 _v, uint256 _r, uint256 _s) public {
    bytes32 hash = keccak256(abi.encodePacked(this, msg.sender, _expiry));
    address signer = ecrecover(hash, _v, _r, _s);
    require(signer == adminAddr, "Invalid signature");
    require(block.timestamp > _expiry, "Timed out");

  }


  function createBlob() external view returns (bytes memory) {
    string memory s = "The quick brown fox jumps over the lazy dog12345678901234567890The quick brown fox jumps over the lazy dog12345678901234567890";
    bytes32 a = bytes32(0);
    bool b = true;
    uint256 c = 123456789;
    bytes memory blob = abi.encode(a, b, c, s);
    return blob;
  }


  uint256 public value;

  function processBlob1(bytes calldata _blob) external {
    string memory s;
    bytes32 a;
    bool b;
    uint256 c;
    (a, b, c, s) = abi.decode(_blob,(bytes32, bool, uint256, string));
    value = c;

  }

  function processBlob2(bytes calldata _blob) external {
    uint256 c;
    (, , c, ) = abi.decode(_blob,(bytes32, bool, uint256, string));
    value = c;

  }

  function processBlob3(bytes calldata _blob) external {
    uint256 c;
    (, , c) = abi.decode(_blob,(bytes32, bool, uint256));
    value = c;

  }

  function processBlob4(bytes calldata _blob) external {
    bytes memory blob = _blob;
    uint256 startOffset = 64;
    uint256 x;
    assembly {
      x := mload(add(blob, add(32, startOffset)))
    }
    value = x;
  }

  function processBlob5(bytes calldata ) external {
    uint256 x;
    assembly {
      calldatacopy(0x0, 132, 32)
      x := mload(0x0)
    }
    value = x;
  }
  event Add1(uint256 indexed val, uint256 val2, bytes val3);
  event Add(uint256 val);

  function add1(uint256 _val) external {
    emit Add(_val);
  }

}