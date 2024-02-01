## Getting Started

### Requirements
- git
  - Check if you git installed by git --version
- foundry
  - Check if you have foundry installed by forge --version

### Quickstart
```bash
git clone https://github.com/priyanshuveb/TokenAirdrop-foundry.git
cd TokenAirdrop-foundry
forge build
```

## Usage

### Deploy
- Local
 ```bash
make deploy-anvil
 ```
 - On-Chain
  ```bash
  make deploy-sepolia
  ```
Note: You can change the parameters in the makefile accordingly to deploy it on any other chain

## Testing
```bash
forge test
```
## Test Coverage
```bash
forge coverage
```

## Scripts
- Token
- Airdrop

## Estimate Gas
```bash
forge snapshot
```

## Formatting
```bash
forge fmt
```

