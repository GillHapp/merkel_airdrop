// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract MerkleAirdrop {
    using SafeERC20 for IERC20;
    address[] claimers;
    bytes32 public immutable i_merkleRoot;
    IERC20 public immutable i_airdropToken;

    mapping(address => bool) public claimed;

    event Claimed(address indexed claimer, uint256 amount);

    constructor(bytes32 merkleRoot, IERC20 airdropToken) {
        i_merkleRoot = merkleRoot;
        i_airdropToken = airdropToken;
    }

    function claim(uint256 amount, bytes32[] calldata proof) external {
        require(!claimed[msg.sender], "Already claimed");
        require(
            MerkleProof.verify(
                proof,
                i_merkleRoot,
                keccak256(
                    bytes.concat(keccak256(abi.encode(msg.sender, amount)))
                )
            ),
            "Invalid proof"
        );

        claimed[msg.sender] = true;
        claimers.push(msg.sender);
        emit Claimed(msg.sender, amount);
        i_airdropToken.safeTransfer(msg.sender, amount);
    }
}
