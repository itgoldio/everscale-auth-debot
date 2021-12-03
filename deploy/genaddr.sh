. ../env.sh

DEBOT_KEYS="keys/debot/debot.keys.json"
DEBOT_ADDR="addr/debot/debot.txt"

ADDR_DEBOT=$($TON_CLI genaddr --setkey $DEBOT_KEYS --wc 0 $DEBOT_TVC $DEBOT_ABI | grep "Raw address: " | awk '{split($0,a,": "); print a[2]}')

echo $ADDR_DEBOT
