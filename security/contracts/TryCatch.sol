// SPDX-License-Identifier: MIT
pragma solidity >=0.8 <0.9.0;

contract Other {
    function func(uint256) external pure returns (uint256) {
        return 0;
    }
}

contract TryCatch {
    uint256 val;
    Other otherContract;

    error Panic1(uint256 _code);

    function doTryCatchOtherContract(uint256 _param) external {
        try otherContract.func(_param) returns (uint256 v) {
            val = v;
        } catch Error(string memory reason) {
            revert(reason);
        } catch Panic(uint256 errorCode) {
            revert Panic1(errorCode);
        } catch (bytes memory /* lowLevelData */) {
        }
    }
}

