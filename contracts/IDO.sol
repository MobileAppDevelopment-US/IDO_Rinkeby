// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./IERC20.sol";

contract IDO {

    event BuyIDOToken(address _addres, uint _value);

    constructor(address _IDOTokenAddress, address payable _withdrawAddress) {
        Admins[msg.sender] = true;
        IDOTokenAddress = _IDOTokenAddress;
        withdrawAddress = _withdrawAddress;
    }

    uint256 public RoundID;
    uint256 public currentRoundID;
    address public IDOTokenAddress;
    address payable public withdrawAddress;

    struct round {
        uint256 start;
        uint256 end;
        uint256 roundValue; // we want to get from this Round of IDO
        uint256 maxValue;
        uint256 minValue;
        uint256 tokenRateToEth;
        bool active;
    }

    mapping(address => bool) Admins;
    mapping(uint256 => round) Rounds;
    mapping(address => mapping(uint256 => uint256)) public Users;
    mapping(address => uint256) public UsersTotalValue;

    modifier onlyAdmin() {
        require(Admins[msg.sender] == true, "Only admins");
        _;
    }

    function addRound(
        uint256 _start,
        uint256 _end,
        uint256 _roundValue,
        uint256 _maxValue,
        uint256 _minValue,
        uint256 _tokenRateToEth
    ) public onlyAdmin {
        require(currentRoundID == 0, "Only one round");
        RoundID += 1;
        Rounds[RoundID].start = _start;
        Rounds[RoundID].end = _end;
        Rounds[RoundID].roundValue = _roundValue;
        Rounds[RoundID].maxValue = _maxValue;
        Rounds[RoundID].minValue = _minValue;
        Rounds[RoundID].tokenRateToEth = _tokenRateToEth;
        Rounds[RoundID].active = true;
    }

    function closeRound(uint256 _roundID) public onlyAdmin {
        currentRoundID = 0;
        Rounds[_roundID].active = false;
    }

    function getEthersForIDO() public payable {
        require(
            block.timestamp > Rounds[currentRoundID].start,
            "Active after start"
        );
        require(
            Rounds[currentRoundID].end > block.timestamp,
            "Before and only"
        );
        require(Rounds[currentRoundID].active == true, "Not active round");
        require(Rounds[currentRoundID].maxValue > msg.value, "Max limit");
        require(Rounds[currentRoundID].minValue < msg.value, "Min limit");

        uint256 _value = msg.value * Rounds[currentRoundID].tokenRateToEth;
        IERC20 _token = IERC20(IDOTokenAddress);
        _token.mint(msg.sender, _value);
        withdrawAddress.transfer(msg.value);
        emit BuyIDOToken(msg.sender, msg.value);
    }
}
