// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {MerkleAirdrop} from "../../src/MerkleAirdrop.sol";
import {BagelToken} from "../../src/BagelToken.sol";
import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";

contract MerkleAirdropTest is Test {
    MerkleAirdrop airdrop;
    BagelToken token;
    uint256 amountToCollect = (25 * 1e18); // 25.000000
    uint256 amountToSend = amountToCollect * 4;

    address user;
    uint256 privKey;
    address user1;
    uint256 privKey1;
    address user2;
    uint256 privKey2;
    address user3;
    uint256 privKey3;
    address user4;
    uint256 privKey4;

    function setUp() public {
        (user, privKey) = makeAddrAndKey("user");
        (user1, privKey1) = makeAddrAndKey("user1");
        (user2, privKey2) = makeAddrAndKey("user2");
        (user3, privKey3) = makeAddrAndKey("user3");
        (user4, privKey4) = makeAddrAndKey("user4");

        console.log("User:", user);
        console.log("User 1:", user1);
        console.log("User 2:", user2);
        console.log("User 3:", user3);
        console.log("User 4:", user4);

        token = new BagelToken();
        bytes32 root = 0xbe8c0ca0528696387b5b52486e7bdebf6a1c53e3adcd6df3d566ef338e924e0f;
        airdrop = new MerkleAirdrop(root, token);
        token.mint(token.owner(), amountToSend);
        console.log("token owner:", token.owner());
        token.transfer(address(airdrop), amountToSend);
    }

    function testUserCanClaim() public {
        vm.startPrank(user);
        bytes32[] memory proof = new bytes32[](2);
        proof[
            0
        ] = 0xef54b0c83407e0c74021e9c900344391f8b30fb6c98e7689f3c6015840959d08;
        proof[
            1
        ] = 0xaf54f4c1ffaace224204799f4ac4ae7b9ec3437ee6e3e72a911513f0ed95ba8b;

        airdrop.claim(amountToCollect, proof);
        assertEq(token.balanceOf(user), amountToCollect);
        assertEq(airdrop.claimed(user), true);
    }
}
