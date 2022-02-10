/* Please read and review the Terms and Conditions governing this
   Merkle Drop by visiting the Trustlines Foundation homepage. Any
   interaction with this smart contract, including but not limited to
   claiming Trustlines Network Tokens, is subject to these Terms and
   Conditions.
 */

pragma solidity 0.8.3;

import "./NFT_1155.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IMerkleDistributor.sol";

contract MerkleDrop is IMerkleDistributor, Ownable {
    address public immutable override token;
    bytes32 public override merkleRoot;

    mapping(address => bool) public withdrawn;
    mapping(address => uint256) public withdrawn_id;

    constructor(address token_, bytes32 merkleRoot_) public {
        token = token_;
        merkleRoot = merkleRoot_;
    }

    function setMerkleRoot(bytes32 merkleRoot_) public onlyOwner {
        merkleRoot = merkleRoot_;
    }

    function isClaimed(address recipient) public view override returns (bool) {
        // recipint + tokenuri
        return withdrawn[recipient];
    }

    function claimedTokenId(address recipient) public view returns (uint256) {
        // recipint + tokenuri
        return withdrawn_id[recipient];
    }

    function claim_old(uint256 _id, bytes32[] calldata proof)
        external
        override
    {
        require(
            !isClaimed(msg.sender),
            "You have already withdrawn your entitled token."
        );
        require(
            verifyEntitled(msg.sender, _id, proof),
            "The proof could not be verified."
        );

        MENFT(token).mint(msg.sender, _id, 1);
        withdrawn[msg.sender] = true;
        withdrawn_id[msg.sender] = _id;
        emit Claimed(msg.sender, _id, 1);
    }

    function st2num(string memory numString) public pure returns (uint256) {
        uint256 val = 0;
        bytes memory stringBytes = bytes(numString);
        for (uint256 i = 0; i < stringBytes.length; i++) {
            uint256 exp = stringBytes.length - i;
            bytes1 ival = stringBytes[i];
            uint8 uval = uint8(ival);
            uint256 jval = uval - uint256(0x30);

            val += (uint256(jval) * (10**(exp - 1)));
        }
        return val;
    }

    function claim(string calldata tokenURI, bytes32[] calldata proof)
        external
        override
    {
        uint256 _id = st2num(tokenURI);
        require(
            !isClaimed(msg.sender),
            "You have already withdrawn your entitled token."
        );
        require(
            verifyEntitled(msg.sender, _id, proof),
            "The proof could not be verified."
        );

        MENFT(token).mint(msg.sender, _id, 1);
        withdrawn[msg.sender] = true;
        withdrawn_id[msg.sender] = _id;
        emit Claimed(msg.sender, _id, 1);
    }

    function verifyEntitled(
        address recipient,
        uint256 _id,
        bytes32[] memory proof
    ) public view returns (bool) {
        // We need to pack the 20 bytes address to the 32 bytes value
        // to match with the proof made with the python merkle-drop package
        bytes32 leaf = keccak256(
            abi.encodePacked(abi.encodePacked(recipient, _id), _id)
        );
        return verifyProof(leaf, proof);
    }

    function verifyProof(bytes32 leaf, bytes32[] memory proof)
        internal
        view
        returns (bool)
    {
        bytes32 currentHash = leaf;

        for (uint256 i = 0; i < proof.length; i += 1) {
            currentHash = parentHash(currentHash, proof[i]);
        }

        return currentHash == merkleRoot;
    }

    function parentHash(bytes32 a, bytes32 b) internal pure returns (bytes32) {
        if (a < b) {
            return keccak256(abi.encode(a, b));
        } else {
            return keccak256(abi.encode(b, a));
        }
    }
}
