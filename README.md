# Token Airdrop

The repo contains two contracts, one is ERC20-Token and second is the Airdrop contract for the forementioned token. After deploying this successfully you will have a token contract and its aidrop contract ready

<br>

The repo goes through following learnings about foundry:
- Writing scripts to deploy contracts
- Write intensive test cases
- Writing scripts to interact with your deployed contracts
- To read input from an external file for a funcion argument

## Getting Started

### Requirements
- git
  - Check if you have git installed by ```git --version```
- foundry
  - Check if you have foundry installed by ```forge --version```

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
```bash
make interact-token-sepolia
```
- Airdrop
```bash
make interact-airdrop-sepolia
```
Note: You can change the parameters in the makefile accordingly to interact with different functions


## Estimate Gas
```bash
forge snapshot
```

## Formatting
```bash
forge fmt
```

