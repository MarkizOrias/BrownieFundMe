from brownie import network, config, accounts, MockV3Aggregator

FORKED_LOCAL_ENVIRONMENTS = ["mainnet-fork-dev"]
LOCAL_BLOCKCHAIN_ENVIRONMENTS = ["development", "ganache-local"]

DECIMALS = 8
PRICE = 200000000000


def get_account():
    if (
        network.show_active() in LOCAL_BLOCKCHAIN_ENVIRONMENTS
        or network.show_active() in FORKED_LOCAL_ENVIRONMENTS
    ):
        return accounts[0]
    else:
        return accounts.add(config["wallets"]["from_key"])
    # if not in the development network, it will pull from config


def deploy_mocks():
    print(f"The active network is {network.show_active()}")
    print(f"Deploying Mocks...")
    if len(MockV3Aggregator) <= 0:
        # checking the length of an array of deployed contract called MockV3Aggregator to deploy it only once
        MockV3Aggregator.deploy(
            DECIMALS,
            PRICE,
            {"from": get_account()}
            # from web3 import Web3 in head, Web3.toWei(2000, "ether") replacing 2000000000000000000000
        )
    print("Mocks deployed!")
