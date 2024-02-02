-include .env

build:; forge build

deploy-anvil:
	forge script script/DeployTestToken.s.sol:DeployTestToken "GameStop" "GSTP" 100000000 18 \
	--rpc-url anvil --private-key $(PRIVATE_KEY_ANVIL) --broadcast -vvv \
	--sig 'run(string,string,uint256,uint8)'

deploy-token-sepolia:
	forge script script/DeployTestToken.s.sol:DeployTestToken "GameStop" "GSTP" 100000000 18 \
	--rpc-url sepolia --private-key $(PRIVATE_KEY_SEPOLIA) --broadcast \
	--sig 'run(string,string,uint256,uint8)' -vvvv --verify --etherscan-api-key sepolia 

deploy-airdrop-sepolia:
	forge script script/DeployAirdrop.s.sol:DeployAirdrop 0x94B46C7fE53Bac1Bbb94FA980975F53Bc7DF5F8D 0xCCE71ef4bc4617bf3f7b28722e6F69C760797d43 \
	--rpc-url sepolia --private-key $(PRIVATE_KEY_SEPOLIA) --broadcast \
	--sig 'run(address,address)' -vvvv --verify --etherscan-api-key sepolia

interact-airdrop-sepolia:
	forge script script/InteractionAirdrop.s.sol:SetAirdropTimeline --rpc-url sepolia --private-key $(PRIVATE_KEY_SEPOLIA) --broadcast -vvvv

interact-token-sepolia:
	forge script script/InteractionToken.s.sol:GiveAllowanceToAirdropContract --rpc-url sepolia --private-key $(PRIVATE_KEY_SEPOLIA) --broadcast -vvvv