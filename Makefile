-include .env

build:; forge build

interact:
		forge script script/Interactions.s.sol:Interactions --rpc-url $(RPC_URL_ANVIL) --private-key $(PRIVATE_KEY_ANVIL) --broadcast -vvv

deploy-anvil:
	forge script script/DeployTestToken.s.sol:DeployTestToken "GameStop" "GSTP" 100000000 18 \
	--rpc-url anvil --private-key $(PRIVATE_KEY_ANVIL) --broadcast -vvv \
	--sig 'run(string,string,uint256,uint8)'

deploy-sepolia:
	forge script script/DeployTestToken.s.sol:DeployTestToken "GameStop" "GSTP" 100000000 18 \
	--rpc-url sepolia --private-key $(PRIVATE_KEY_SEPOLIA) --broadcast \
	--sig 'run(string,string,uint256,uint8)' -vvvv --verify --etherscan-api-key sepolia 
