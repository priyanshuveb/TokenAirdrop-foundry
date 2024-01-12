-include .env

deploy-anvil:
	forge script script/DeployTestToken.s.sol:DeployTestToken --rpc-url $(RPC_URL_ANVIL) --private-key $(PRIVATE_KEY_ANVIL) --broadcast -vvv

interact:
		forge script script/Interactions.s.sol:Interactions --rpc-url $(RPC_URL_ANVIL) --private-key $(PRIVATE_KEY_ANVIL) --broadcast -vvv
