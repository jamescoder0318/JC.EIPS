// SPDX-License-Identifier: CC0-1.0

pragma solidity ^0.8.16;

interface ISoulbound {

    /**
     * @notice Used to check whether the given token is soulbound or not.
     * @param tokenId ID of the token being checked
     * @return Boolean value indicating whether the given token is soulbound
     */
    function isSoulbound(uint256 tokenId) external view returns (bool);
}