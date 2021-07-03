pragma solidity ^0.8.5;
// import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "./CallerContractInterface.sol";
import "hardhat/console.sol";

// contract BettingOracle is Ownable {
contract BettingOracle {
    uint256 private randNonce = 0;
    uint256 private modulus = 1000;
    mapping(uint256 => bool) pendingRequests;
    event GetCorrectHorseEvent(address callerAddress, uint256 id);
    event SetCorrectHorseEvent(uint256 ethPrice, address callerAddress);

    function getCorrectHorse(address callerAddress) public returns (uint256) {
        console.log(
            "ORACLE: getCorrectHorse msg.sender: ",
            msg.sender,
            callerAddress
        );

        // in original example (https://cryptozombies.io/en/lesson/15/chapter/1) they used msg.sender, but it seems not to work

        randNonce++;
        uint256 id = uint256(
            keccak256(
                abi.encodePacked(block.timestamp, callerAddress, randNonce)
            )
        ) % modulus;
        pendingRequests[id] = true;
        emit GetCorrectHorseEvent(callerAddress, id);
        return id;
    }

    function sendCorrectHorse(
        uint8 correctHorse,
        address _callerAddress,
        uint256 _id //    ) public onlyOwner {
    ) public {
        require(
            pendingRequests[_id],
            "This request is not in my pending list."
        );
        delete pendingRequests[_id];
        CallerContracInterface callerContractInstance;
        callerContractInstance = CallerContracInterface(_callerAddress);
        callerContractInstance.oracleCallback(correctHorse, _id);
        // emit SetCorrectHorseEvent(_ethPrice, _callerAddress);
    }
}
