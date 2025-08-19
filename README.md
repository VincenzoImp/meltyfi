# MeltyFi Protocol

**Making the illiquid liquid** - An innovative peer-to-pool lending and borrowing protocol with NFT collateral

[![GitHub](https://img.shields.io/badge/GitHub-Repository-blue)](https://github.com/VincenzoImp/MeltyFi.NFT)
[![Live Demo](https://img.shields.io/badge/Live-Demo-green)](https://meltyfi.nft)
[![Goerli Testnet](https://img.shields.io/badge/Network-Goerli-orange)](https://goerli.etherscan.io)

## 🎯 Overview

MeltyFi is a revolutionary DeFi protocol that enables **peer-to-pool lending and borrowing with NFT collateral** through an innovative lottery-based system. Unlike traditional NFT-backed lending platforms, MeltyFi eliminates the risk of involuntary liquidation by operating independently of off-chain factors like floor prices.

### Key Features

- 🔒 **No Liquidation Risk**: NFTs are never forcibly liquidated due to price fluctuations
- 🎲 **Lottery-Based Funding**: Lenders participate through a transparent lottery system
- 🏆 **Win-Win Mechanism**: Benefits for both borrowers and lenders
- 🎮 **Gamified Experience**: WonkaBars (lottery tickets) and ChocoChips (governance tokens)
- 🌐 **Decentralized**: No dependence on external oracles for price determination

## 🏗️ Architecture

### Smart Contracts

#### Core Contracts
- **MeltyFiNFT** (`0x6c1030B8BbE523671Bcfd774Ae59ef620f9f31b4`) - Main protocol logic
- **MeltyFiDAO** (`0xC4AA65a48fd317070F1A5aC5eBAC70F9d022Fb1e`) - Governance contract
- **ChocoChip** - ERC-20 governance token with voting capabilities
- **LogoCollection** - ERC-1155 meme token for protocol branding
- **VRFv2DirectFundingConsumer** - Chainlink VRF for random winner selection

#### Token Standards
- **ERC-721**: NFT collateral support
- **ERC-1155**: WonkaBars (lottery tickets) and LogoCollection
- **ERC-20**: ChocoChip governance token with EIP-2612 permit functionality

### Frontend Architecture

The frontend is built with modern web technologies for optimal user experience:

- **React 18** - Component-based UI framework
- **React-Bootstrap** - Responsive design components
- **Ethers.js** - Ethereum blockchain interaction
- **thirdweb** - Web3 authentication and wallet connection
- **MetaMask** - Primary wallet integration
- **OpenSea API** - NFT metadata retrieval

## 🚀 Getting Started

### Prerequisites

- Node.js (v16 or higher)
- MetaMask browser extension
- Goerli testnet ETH ([faucet](https://goerlifaucet.com))

### Backend Setup

```bash
# Clone the repository
git clone https://github.com/VincenzoImp/MeltyFi.NFT
cd MeltyFi.NFT/src/back-end/MeltyFiProtocol

# Install dependencies
npm install

# Create environment file
cp .env.example .env
# Add your ALCHEMY_API_KEY, GOERLI_PRIVATE_KEY, and ETHERSCAN_API_KEY

# Compile contracts
npx hardhat compile

# Run tests
npx hardhat test

# Deploy to Goerli (if needed)
npx hardhat run scripts/deploy.js --network goerli
```

### Frontend Setup

```bash
# Navigate to frontend directory
cd src/front-end/meltyfi.nft

# Install dependencies
npm install

# Start development server
npm start
```

The application will be available at `http://localhost:3000`

### Required Dependencies

#### Backend
```json
{
  "@openzeppelin/contracts": "^4.8.0",
  "@chainlink/contracts": "^0.6.0",
  "hardhat": "^2.12.0",
  "@nomicfoundation/hardhat-toolbox": "^2.0.0",
  "hardhat-docgen": "^1.3.0",
  "dotenv": "^16.0.0"
}
```

#### Frontend
```json
{
  "react": "^18.2.0",
  "react-bootstrap": "^2.5.0",
  "ethers": "^5.7.0",
  "@thirdweb-dev/react": "^3.10.0",
  "@thirdweb-dev/sdk": "^3.10.0"
}
```

## 📖 How It Works

### For Borrowers

1. **Create Lottery**: Select an NFT from your collection as collateral
2. **Set Parameters**: Define ticket price (in Wei) and expiration date
3. **Receive Funds**: Get immediate liquidity as tickets are sold
4. **Repay or Default**: Repay before expiration to get your NFT back, or let the lottery conclude

### For Lenders

1. **Browse Lotteries**: View active lotteries with different NFTs and terms
2. **Buy WonkaBars**: Purchase lottery tickets with ETH
3. **Win or Earn**: Win the NFT if selected, or earn ChocoChips for participation
4. **Governance**: Use ChocoChips for protocol governance decisions

### Lottery States

- **Active**: Tickets can be purchased, funds flow to borrower
- **Concluded**: Random winner selected, NFT transferred to winner
- **Cancelled**: Borrower repaid loan, participants get refunds + ChocoChips

## 🎮 User Interface

### Pages

#### Home Page
- Protocol introduction and explanation
- Key features and benefits overview
- Getting started guide

#### Lotteries Page
- Browse all active lotteries
- Filter by status and parameters
- Purchase WonkaBars (lottery tickets)
- Real-time lottery information

#### Profile Page
- View owned lotteries and their status
- Check WonkaBar holdings and win probabilities
- Monitor ChocoChip balance
- Manage active positions

#### Create Lottery Tab
- Select NFTs from connected wallet
- Set lottery parameters (price, duration)
- Approve NFT transfer and create lottery
- Real-time transaction feedback

## 🔧 Technical Implementation

### Smart Contract Features

- **Chainlink VRF**: Provably random winner selection
- **Chainlink Automation**: Automated lottery conclusion
- **Gas Optimization**: Efficient batch operations
- **Access Control**: Role-based permissions
- **Upgradeable Patterns**: Future-proof architecture

### Frontend Features

- **Responsive Design**: Mobile-first approach with Bootstrap
- **Real-time Updates**: Live lottery status and blockchain state
- **Error Handling**: Comprehensive user feedback
- **MetaMask Integration**: Seamless wallet connection
- **Transaction Management**: Clear status and confirmation flows

### Security Measures

- **OpenZeppelin Standards**: Battle-tested contract implementations
- **Reentrancy Guards**: Protection against common attacks
- **Input Validation**: Comprehensive parameter checking
- **Emergency Controls**: Circuit breakers for critical functions

## 🌐 Live Deployment

### Mainnet Addresses (Goerli Testnet)

- **MeltyFiNFT**: [`0x6c1030B8BbE523671Bcfd774Ae59ef620f9f31b4`](https://goerli.etherscan.io/address/0x6c1030B8BbE523671Bcfd774Ae59ef620f9f31b4)
- **MeltyFiDAO**: [`0xC4AA65a48fd317070F1A5aC5eBAC70F9d022Fb1e`](https://goerli.etherscan.io/address/0xC4AA65a48fd317070F1A5aC5eBAC70F9d022Fb1e)

### Live Applications

- **MeltyFi.NFT DApp**: [https://meltyfi.nft](https://meltyfi.nft)
- **MeltyFi.DAO DApp**: [https://meltyfi.dao](https://meltyfi.dao) *(Coming Soon)*

### Example Transactions

- **Create Lottery**: [`0xe68f3f6...`](https://goerli.etherscan.io/tx/0xe68f3f68b00dce4c299d0205dfbc72c302ae4d5e089b16d3c024755db70ffdf3)
- **Melt WonkaBars**: [`0xd957d27...`](https://goerli.etherscan.io/tx/0xd957d276b5499f6ad40e62a47ad9fd74f255f0a6fc6e1240903fd8aaf1337c3f)

## 👥 Team

- **Vincenzo Imperati** - Project Manager, Backend Developer, Designer
- **Benigno Ansanelli** - Frontend Developer (Lottery Functionality), Documentation
- **Andrea Princic** - Frontend Developer (Profile Functionality), UX Design

## 🛠️ Development Tools

### Blockchain Development
- **Hardhat** - Development environment and testing framework
- **Remix** - Online Solidity IDE for contract development
- **Alchemy** - Ethereum node provider
- **Etherscan** - Contract verification and monitoring

### Frontend Development
- **Create React App** - Development bootstrapping
- **React Router** - Client-side routing
- **Web3 Modal** - Wallet connection management

### External APIs
- **OpenSea Testnets API** - NFT metadata and collection data
- **Chainlink Oracles** - VRF and Automation services

## 📚 Documentation

### Generated Documentation
- Smart contract documentation is auto-generated using `hardhat-docgen`
- Available in the `/docs` directory after compilation

### Research Paper
- Comprehensive academic report available in LaTeX format
- Covers background, implementation, and analysis
- Located in `/report/latex/` directory

## 🔄 Workflow Examples

### Creating a Lottery

```solidity
// 1. Approve NFT transfer
nftContract.approve(meltyFiAddress, tokenId);

// 2. Create lottery
meltyFi.createLottery(
    nftContractAddress,
    tokenId,
    ticketPrice,
    expirationTimestamp,
    maxTickets
);
```

### Participating in a Lottery

```solidity
// Purchase WonkaBars (lottery tickets)
meltyFi.buyWonkaBars(lotteryId, quantity, { value: totalCost });
```

### Claiming Rewards

```solidity
// Melt WonkaBars to claim NFT or ChocoChips
meltyFi.meltWonkaBars(lotteryId, quantity);
```

## 🚧 Known Limitations

- **Goerli Testnet Only**: Currently deployed on testnet for testing
- **Oracle Dependency**: Relies on Chainlink services for automation
- **Gas Costs**: Complex operations may have higher gas requirements
- **UI Completeness**: DAO interface not yet implemented

## 🔮 Future Roadmap

- **Mainnet Deployment**: Production deployment on Ethereum mainnet
- **Layer 2 Support**: Polygon, Arbitrum, and Optimism integration
- **Advanced Features**: Dutch auctions, multi-NFT lotteries
- **Mobile App**: Native mobile application development
- **Cross-chain**: Bridge to multiple blockchain networks

## 🤝 Contributing

We welcome contributions! Please feel free to submit issues, feature requests, or pull requests.

### Development Guidelines
1. Follow existing code style and conventions
2. Add tests for new functionality
3. Update documentation as needed
4. Test on Goerli testnet before submitting

## 📄 License

This project is open source. Please refer to the repository for license details.

## 🔗 Links

- **GitHub Repository**: [VincenzoImp/MeltyFi.NFT](https://github.com/VincenzoImp/MeltyFi.NFT)
- **Live Application**: [meltyfi.nft](https://meltyfi.nft)
- **Documentation**: Available in repository `/docs` directory
- **Goerli Faucet**: [goerlifaucet.com](https://goerlifaucet.com)
- **OpenSea Testnet**: [testnets.opensea.io](https://testnets.opensea.io)

---

**MeltyFi Protocol** - Revolutionizing NFT-backed lending through innovative lottery mechanics and decentralized governance.
