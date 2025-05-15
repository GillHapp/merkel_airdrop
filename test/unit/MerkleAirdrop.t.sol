// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {MerkleAirdrop} from "../../src/MerkleAirdrop.sol";
import {BagelToken} from "../../src/BagelToken.sol";
import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";

contract MerkleAirdropTest is Test {
    MerkleAirdrop airdrop;
    BagelToken token;
    uint256 amountToCollect = 25 ether;
    uint256 amountToSend = amountToCollect * 4;

    address user = 0x6CA6d1e2D5347Bfab1d91e883F1915560e09129D;

    function setUp() public {
        console.log("User:", user);
        console.log("Amount to collect:", amountToCollect);

        // Deploy BagelToken and mint
        token = new BagelToken();
        token.mint(token.owner(), amountToSend);

        // Deploy airdrop with correct Merkle root
        bytes32 root = 0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;
        airdrop = new MerkleAirdrop(root, token);

        // Send tokens to airdrop contract
        token.transfer(address(airdrop), amountToSend);
    }

    function testUserCanClaim() public {
        // Start impersonation of known user
        vm.startPrank(user);

        // Construct proof from JSON
        bytes32[] memory proof = new bytes32[](2);
        proof[
            0
        ] = 0x0fd7c981d39bece61f7499702bf59b3114a90e66b51ba2c53abdf7b62986c00a;
        proof[
            1
        ] = 0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;

        // Check if user is eligible

        // Compute leaf hash
        // bytes32 leaf = keccak256(
        //     abi.encode(
        //         0x6CA6d1e2D5347Bfab1d91e883F1915560e09129D,
        //         "25000000000000000000"
        //     )
        // );
        // console.logBytes32(leaf);
        // bytes32 leaf2 = keccak256(
        //     bytes.concat(
        //         keccak256(
        //             abi.encode(
        //                 0x6CA6d1e2D5347Bfab1d91e883F1915560e09129D,
        //                 "25000000000000000000"
        //             )
        //         )
        //     )
        // );
        // console.logBytes32(leaf2);

        // Execute claim
        airdrop.claim(amountToCollect, proof);

        // Check results
        assertEq(token.balanceOf(user), amountToCollect);
        assertEq(airdrop.claimed(user), true);

        vm.stopPrank();
    }
}
