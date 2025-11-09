// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract MerkleAirdrop {
    using SafeERC20 for IERC20;

    error MerkleAirdrop__InvalidProof();
    error MerkleAirdrop__AlreadyClaimed();

    address[] claimers;
    bytes32 private immutable i_merkelRoot;
    IERC20 private immutable i_airdropToken;
    mapping(address claimers => bool claimed) s_hasClaimed;

    event Claim(address account, uint256 amount);

    constructor(bytes32 merkelRoot, IERC20 airdropToken) {
        i_merkelRoot = merkelRoot;
        i_airdropToken = airdropToken;
    }

    function claim(address account, uint256 amount, bytes32[] calldata merkleProof) external {
        if (s_hasClaimed[account] == true) {
            revert MerkleAirdrop__AlreadyClaimed();
        }
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(account, amount)))); // we have to hash it twice bcz if we have 2 data that prouces same hashes it will create a problem (pre-image attack). keccak256 hashing algorithm is resistance to clashes but but still its standards so we have to do that.
        if (!MerkleProof.verify(merkleProof, i_merkelRoot, leaf)) {
            revert MerkleAirdrop__InvalidProof();
        }
        s_hasClaimed[account] = true;
        emit Claim(account, amount);
        i_airdropToken.safeTransfer(account, amount);
    }

    function getMerkleRoot() external view returns (bytes32) {
        return i_merkelRoot;
    }

    function getAirdropToken() external view returns (IERC20) {
        return i_airdropToken;
    }
}
