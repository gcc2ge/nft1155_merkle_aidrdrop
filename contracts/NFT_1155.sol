pragma solidity 0.8.3;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract MENFT is ERC1155, Ownable {
    // NFT name
    string public name;

    // NFT symbol
    string public symbol;

    uint256 private _tokenIds;

    address private _merkle_drop_addr;

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _uri
    ) public ERC1155(_uri) {
        name = _name;
        symbol = _symbol;
    }

    function setMerkleDrop(address merkle_drop_addr) external onlyOwner {
        _merkle_drop_addr = merkle_drop_addr;
    }

    modifier onlyMerkleDrop() {
        require(msg.sender == _merkle_drop_addr);
        _;
    }

    function add(uint256 ids) external onlyOwner {
        require(ids > _tokenIds, "Invalid ID");
        _tokenIds = ids;
    }

    function setBaseURI(string calldata _uri) external onlyOwner {
        _setURI(_uri);
    }

    function uri(uint256 id) public view override returns (string memory) {
        require(id <= _tokenIds, "URI query for nonexistent token");

        string memory baseUri = super.uri(0);
        return string(abi.encodePacked(baseUri, Strings.toString(id)));
    }

    function mint(
        address receiver,
        uint256 _id,
        uint256 quantities
    ) external onlyMerkleDrop {
        require(_id <= _tokenIds, "Invalid ID");
        _mint(receiver, _id, quantities, new bytes(0));
    }

    function mintBatch(
        address receiver,
        uint256[] calldata ids,
        uint256[] calldata quantities
    ) external onlyOwner {
        require(ids.length == quantities.length, "Mismatched array lengths");

        for (uint256 i = 0; i < ids.length; i++) {
            require(ids[i] <= _tokenIds, "Invalid ID");
        }

        _mintBatch(receiver, ids, quantities, new bytes(0));
    }

    function tokensOfOwner(address _owner)
        external
        view
        returns (uint256[] memory ownerTokens)
    {
        uint256 index;
        uint256 tokenCount = 0;

        for (index = 0; index < _tokenIds; index++) {
            uint256 balance = balanceOf(_owner, index + 1);
            if (balance > 0) {
                tokenCount += 1;
            }
        }

        uint256[] memory result = new uint256[](tokenCount);
        uint256 index2;
        for (index = 0; index < _tokenIds; index++) {
            uint256 balance = balanceOf(_owner, index + 1);
            if (balance > 0) {
                result[index2] = index + 1;
                index2 += 1;
            }
        }
        return result;
    }
}
