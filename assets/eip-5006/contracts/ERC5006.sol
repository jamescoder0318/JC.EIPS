// SPDX-License-Identifier: CC0-1.0

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "./IERC5006.sol";

contract ERC5006 is ERC1155, IERC5006 {
    /** mapping(tokenId => mapping(user=>amount)) */
    mapping(uint256 => mapping(address => uint256)) private _userAllowances;

    /** mapping(tokenId => mapping(owner=>amount)) */
    mapping(uint256 => mapping(address => uint256)) private _frozen;

    /** mapping(tokenId => mapping(owner => mapping(user => amount))) */
    mapping(uint256 => mapping(address => mapping(address => uint256)))
        private _allowances;

    constructor() ERC1155("") {}

    /**
     * @dev Returns the amount of tokens of token type `id` used by `user`.
     *
     * Requirements:
     *
     * - `user` cannot be the zero address.
     */
    function balanceOfUser(address user, uint256 id)
        public
        view
        returns (uint256)
    {
        return _userAllowances[id][user];
    }

    /**
     * @dev Returns the amount of tokens of token type `id` used by `user`.
     *
     * Requirements:
     *
     * - `user` cannot be the zero address.
     * - `owner` cannot be the zero address.
     */ 
    function balanceOfUserFromOwner(
        address user,
        address owner,
        uint256 id
    ) public view returns (uint256) {
        return _allowances[id][owner][user];
    }

    /**
     * @dev Returns the amount of frozen tokens of token type `id` by `owner`.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     */
    function frozenAmountOfOwner(address owner, uint256 id)
        external
        view
        returns (uint256)
    {
        return _frozen[id][owner];
    }    

    /**
     * @dev set the `user` of a NFT
     *
     * Requirements:
     *
     * - `user` The new user of the NFT, the zero address indicates there is no user
     * - `amount` The new user could use
     */ 
    function setUser(
        address owner,
        address user,
        uint256 id,
        uint256 amount
    ) public virtual {
        require(user != address(0), "ERROR: transfer to the zero address");
        address operator = msg.sender;
        require(operator == owner || isApprovedForAll(owner, operator), "ERROR: caller is not owner nor approved");
        uint256 fromBalance = balanceOf(owner, id);
        _frozen[id][owner] -= _allowances[id][owner][user];
        uint256 frozen = _frozen[id][owner];
        require(
            fromBalance - frozen >= amount,
            "ERROR: insufficient balance for setUser"
        );
        unchecked {
            _frozen[id][owner] = frozen + amount;
        }
        _userAllowances[id][user] -= _allowances[id][owner][user];
        _userAllowances[id][user] += amount;
        _allowances[id][owner][user] = amount;

        emit UpdateUser(operator, owner, user, id, amount);
    }

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual override {
        for (uint256 i = 0; i < ids.length; i++) {
            if (from != address(0)) {
                uint256 id = ids[i];
                uint256 fromBalance = balanceOf(from, id);
                uint256 frozen = _frozen[id][from];
                require(
                    fromBalance - frozen >= amounts[i],
                    "ERROR: insufficient balance for transfer"
                );
            }
        }
    }

    /// @dev See {IERC165-supportsInterface}.
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC5006).interfaceId || super.supportsInterface(interfaceId);
    }
}