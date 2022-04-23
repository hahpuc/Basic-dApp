// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.7.0 <0.9.0;

contract MyTotalIQ {
    uint256 currentIQ;

    constructor() {
        currentIQ = 0;
    }

    function increaseIQ(uint256 value) public {
        currentIQ += value;
    }

    function decreaseIQ(uint256 value) public {
        require(currentIQ > value, "Can not decrease IQ");
        currentIQ -= value;
    }

    function getCurrentIQ() public view returns (uint256) {
        return currentIQ;
    }
}
