// SPDX-License-Identifier: MIT

pragma solidity >=0.8.9 <0.9.0;

import 'erc721a/contracts/ERC721A.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/cryptography/MerkleProof.sol';
import '@openzeppelin/contracts/security/ReentrancyGuard.sol';

contract BoraDummyColl is ERC721A, Ownable, ReentrancyGuard {

  using Strings for uint256;

  bytes32[5] public merkleRoots; // having multiple roots for each group of allow lists

  mapping(address => uint256) public numberOfMints;
  mapping(address => uint256) public numberOfAllowance;

  string public uriPrefix = '';
  string public uriSuffix = '.json';
  string public hiddenMetadataUri;
  
  uint256 public maxSupply;

  bool public isPublicMintOpen = false;
  bool public whitelistMintEnabled = true;
  bool public revealed = false;

  constructor(
    string memory _tokenName,
    string memory _tokenSymbol,
    uint256 _maxSupply,
    string memory _hiddenMetadataUri
  ) ERC721A(_tokenName, _tokenSymbol) {
    maxSupply = _maxSupply;
    setHiddenMetadataUri(_hiddenMetadataUri);
  }

  modifier mintCompliance(uint256 _mintAmount) {
    require(_mintAmount > 0, 'Invalid mint amount!');
    require(totalSupply() + _mintAmount <= maxSupply, 'Max supply exceeded!');
    _;
  }

  function whitelistMintTest1(uint256 _mintAmount, bytes32[] calldata _merkleProof) public mintCompliance(_mintAmount) returns (uint256){
    // Verify whitelist requirements
    require(whitelistMintEnabled, 'The whitelist sale is not enabled!');
    
    bool isWhitelisted = false;    
    bytes32 leaf = keccak256(abi.encodePacked(_msgSender()));

    // if the address has no allowance record, check the roots
    // TESTING: Check all of them one by one
    if (numberOfAllowance[_msgSender()] == 0){
      if (MerkleProof.verify(_merkleProof, merkleRoots[0], leaf)){
        numberOfAllowance[_msgSender()] = 1;
        isWhitelisted = true;
      }
      else if (MerkleProof.verify(_merkleProof, merkleRoots[1], leaf)){
        numberOfAllowance[_msgSender()] = 2;
        isWhitelisted = true;
      }
      else if (MerkleProof.verify(_merkleProof, merkleRoots[2], leaf)){
        numberOfAllowance[_msgSender()] = 3;
        isWhitelisted = true;
      }
      else if (MerkleProof.verify(_merkleProof, merkleRoots[3], leaf)){
        numberOfAllowance[_msgSender()] = 5;
        isWhitelisted = true;
      }
      else if (MerkleProof.verify(_merkleProof, merkleRoots[4], leaf)){
        numberOfAllowance[_msgSender()] = 10;
        isWhitelisted = true;
      }
    }
    else { // if address already has a allowance record
      isWhitelisted = true;
    }
    
    require((isWhitelisted), "The address is not whitelisted!");

    // Check if it is exceeding the allowance
    require((numberOfMints[_msgSender()] + _mintAmount <= numberOfAllowance[_msgSender()]), "The number of allowance is exceeded!");

    numberOfMints[_msgSender()] += _mintAmount;
    _safeMint(_msgSender(), _mintAmount);

    return numberOfAllowance[_msgSender()] - numberOfMints[_msgSender()];
  }

  function whitelistMintTest2(uint256 _mintAmount, bytes32[] calldata _merkleProof) public mintCompliance(_mintAmount) returns (uint256){
    // Verify whitelist requirements
    require(whitelistMintEnabled, 'The whitelist sale is not enabled!');
    
    bool isWhitelisted = false;
    uint256 rootIndex = 0;    
    bytes32 leaf = keccak256(abi.encodePacked(_msgSender()));

    
    // if the address has no allowance record, check the roots
    // TESTING: Check all of them with a for loop
    if (numberOfAllowance[_msgSender()] == 0){
      for (uint256 i = 0; i < merkleRoots.length; i++){
        if (MerkleProof.verify(_merkleProof, merkleRoots[i], leaf)){
          rootIndex = i;
          isWhitelisted = true;
          break;
        }
      }
      if (rootIndex == 0){
        numberOfAllowance[_msgSender()] = 1;
      }
      else if (rootIndex == 1){
        numberOfAllowance[_msgSender()] = 2;
      }
      else if (rootIndex == 2){
        numberOfAllowance[_msgSender()] = 3;
      }
      else if (rootIndex == 3){
        numberOfAllowance[_msgSender()] = 5;
      }
      else if (rootIndex == 4){
        numberOfAllowance[_msgSender()] = 10;
      }
    }
    else { // if address already has a allowance record
      isWhitelisted = true;
    }
    
    require((isWhitelisted), "The address is not whitelisted!");

    // Check if it is exceeding the allowance
    require((numberOfMints[_msgSender()] + _mintAmount <= numberOfAllowance[_msgSender()]), "The number of allowance is exceeded!");

    numberOfMints[_msgSender()] += _mintAmount;
    _safeMint(_msgSender(), _mintAmount);

    return numberOfAllowance[_msgSender()] - numberOfMints[_msgSender()];
  }

  function whitelistMintTest3(uint256 _mintAmount, bytes32[] calldata _merkleProof) public mintCompliance(_mintAmount) returns (uint256){
    // Verify whitelist requirements
    require(whitelistMintEnabled, 'The whitelist sale is not enabled!');
    
    bool isWhitelisted = false;
    bytes32 leaf = keccak256(abi.encodePacked(_msgSender()));

    
    // if the address has no allowance record, check the roots
    // TESTING: Check all of them : Root index = Number of Allowance
    if (numberOfAllowance[_msgSender()] == 0){
      for (uint256 i = 0; i < merkleRoots.length; i++){
        if (MerkleProof.verify(_merkleProof, merkleRoots[i], leaf)){
          numberOfAllowance[_msgSender()] = i;
          isWhitelisted = true;
          break;
        }
      }
    }
    else { // if address already has a allowance record
      isWhitelisted = true;
    }
    
    require((isWhitelisted), "The address is not whitelisted!");

    // Check if it is exceeding the allowance
    require((numberOfMints[_msgSender()] + _mintAmount <= numberOfAllowance[_msgSender()]), "The number of allowance is exceeded!");

    numberOfMints[_msgSender()] += _mintAmount;
    _safeMint(_msgSender(), _mintAmount);

    return numberOfAllowance[_msgSender()] - numberOfMints[_msgSender()];
  }

  function publicMint() public mintCompliance(1) {
    require(isPublicMintOpen, 'The public mint is not open yet!');
    require(numberOfMints[_msgSender()] == 0, 'The address already claimed!');

    numberOfMints[_msgSender()] += 1;
    _safeMint(_msgSender(), 1);
  }
  
  function mintForAddress(uint256 _mintAmount, address _receiver) public mintCompliance(_mintAmount) onlyOwner {
    _safeMint(_receiver, _mintAmount);
  }

  function walletOfOwner(address _owner) public view returns (uint256[] memory) {
    uint256 ownerTokenCount = balanceOf(_owner);
    uint256[] memory ownedTokenIds = new uint256[](ownerTokenCount);
    uint256 currentTokenId = _startTokenId();
    uint256 ownedTokenIndex = 0;
    address latestOwnerAddress;

    while (ownedTokenIndex < ownerTokenCount && currentTokenId < _currentIndex) {
      TokenOwnership memory ownership = _ownerships[currentTokenId];

      if (!ownership.burned) {
        if (ownership.addr != address(0)) {
          latestOwnerAddress = ownership.addr;
        }

        if (latestOwnerAddress == _owner) {
          ownedTokenIds[ownedTokenIndex] = currentTokenId;

          ownedTokenIndex++;
        }
      }

      currentTokenId++;
    }

    return ownedTokenIds;
  }

  function _startTokenId() internal view virtual override returns (uint256) {
    return 1;
  }

  function tokenURI(uint256 _tokenId) public view virtual override returns (string memory) {
    require(_exists(_tokenId), 'ERC721Metadata: URI query for nonexistent token');

    if (revealed == false) {
      return hiddenMetadataUri;
    }

    string memory currentBaseURI = _baseURI();
    return bytes(currentBaseURI).length > 0
        ? string(abi.encodePacked(currentBaseURI, _tokenId.toString(), uriSuffix))
        : '';
  }

  function setRevealed(bool _state) public onlyOwner {
    revealed = _state;
  }

  function setHiddenMetadataUri(string memory _hiddenMetadataUri) public onlyOwner {
    hiddenMetadataUri = _hiddenMetadataUri;
  }

  function setUriPrefix(string memory _uriPrefix) public onlyOwner {
    uriPrefix = _uriPrefix;
  }

  function setUriSuffix(string memory _uriSuffix) public onlyOwner {
    uriSuffix = _uriSuffix;
  }

  function setPublicMint(bool _state) public onlyOwner {
    isPublicMintOpen = _state;
  }

  function setMerkleRootArray(bytes32 _merkleRoot, uint256 _rootIndex) public onlyOwner {
    merkleRoots[_rootIndex] = _merkleRoot;
  }

  function setWhitelistMintEnabled(bool _state) public onlyOwner {
    whitelistMintEnabled = _state;
  }

  function withdraw() public onlyOwner nonReentrant {   
    // Do not remove this otherwise you will not be able to withdraw the funds.
    (bool os, ) = payable(owner()).call{value: address(this).balance}('');
    require(os);
  }

  function _baseURI() internal view virtual override returns (string memory) {
    return uriPrefix;
  }
}
