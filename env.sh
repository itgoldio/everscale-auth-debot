#set -x

DEBOT_ACTUAL_VERSION="1.1"

LOCALNET=""
DEVNET="https://net1.ton.dev"
MAINNET="https://main.ton.dev"

# NETWORK=$LOCALNET
NETWORK=$DEVNET

#GIVER
TON_TONOSSE_GIVER_KEY="../vendoring/giver.tonosse/GiverV2.keys.json"
TON_TONOSSE_GIVER_ABI="../vendoring/giver.tonosse/GiverV2.abi.json"
TON_TONOSSE_GIVER_ADDR="0:b5e9240fc2d2f1ff8cbb1d1dee7fb7cae155e5f6320e585fcc685698994a19a5"

TON_CLI="/cli/target/release/tonos-cli"
TON_COMPILER="/solc/0.49.0/solc"
TVM_LINKER="/tvm-linker/tvm_linker"
TVM_LINKER_STDLIB="/solc/0.49.0/lib/stdlib_sol.tvm"

DEBOT_ABI="../versions/AuthDebot/$DEBOT_ACTUAL_VERSION/AuthDebot.abi.json"
DEBOT_TVC="../versions/AuthDebot/$DEBOT_ACTUAL_VERSION/AuthDebot.tvc"
DEBOT_DECODED="../versions/AuthDebot/$DEBOT_ACTUAL_VERSION/AuthDebot.decoded"
DEBOT_HASH="../versions/AuthDebot/$DEBOT_ACTUAL_VERSION/AuthDebot.hash"
DEBOT_LOGO="../versions/AuthDebot/$DEBOT_ACTUAL_VERSION/logo.png"

# for rewrite default settings create custom.env.sh 
if [ -f "../custom.env.sh" ]; then
   . ../custom.env.sh
fi
# custom.deploy.env.sh sample
#TON_CLI="/root/cli/tonos-cli"
#TON_COMPILER="/root/solc/0.49.0/solc"
#TVM_LINKER="/root/tvm-linker/tvm_linker"
#TVM_LINKER_STDLIB="/root/solc/0.49.0/lib/stdlib_sol.tvm"
#LOCALNET="http://127.0.0.1"
#NETWORK=$LOCALNET
#GIVER_SH="tonosse.giver.sh"
