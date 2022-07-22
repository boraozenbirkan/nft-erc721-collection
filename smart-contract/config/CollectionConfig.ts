import CollectionConfigInterface from '../lib/CollectionConfigInterface';
import * as Networks from '../lib/Networks';
import * as Marketplaces from '../lib/Marketplaces';
import whitelistAddresses from './whitelist.json';

const CollectionConfig: CollectionConfigInterface = {
  testnet: Networks.ethereumTestnet,
  mainnet: Networks.ethereumMainnet,
  // The contract name can be updated using the following command:
  // yarn rename-contract NEW_CONTRACT_NAME
  // Please DO NOT change it manually!
  contractName: 'BoraDummyColl',
  tokenName: 'Bora Dummy Collection',
  tokenSymbol: 'BDC',
  hiddenMetadataUri: 'ipfs://QmSSZrpJ9zXkWDmR6z6vBWzESG86WjdPos3nw3oFjZEYrn/hidden.json',
  maxSupply: 10000,
  whitelistSale: {
    price: 0.01,
    maxMintAmountPerTx: 1,
  },
  preSale: {
    price: 0.05,
    maxMintAmountPerTx: 2,
  },
  publicSale: {
    price: 0.1,
    maxMintAmountPerTx: 5,
  },
  contractAddress: "0x02168e4922a8936EC54A3c140bF17e482C4331Bd",
  marketplaceIdentifier: 'my-nft-token',
  marketplaceConfig: Marketplaces.openSea,
  whitelistAddresses,
};

export default CollectionConfig;
