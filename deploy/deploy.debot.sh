. ../env.sh

DEBOT_KEYS="keys/debot/debot.keys.json"
DEBOT_ADDR="addr/debot/debot.txt"

if ! [ -d addr/debot/ ]; 
then
    mkdir addr/debot/
fi

if ! [ -d keys/debot/ ]; 
then
    mkdir keys/debot/
fi

ADDR_DEBOT=$($TON_CLI genaddr --setkey $DEBOT_KEYS --wc 0 $DEBOT_TVC $DEBOT_ABI | grep "Raw address: " | awk '{split($0,a,": "); print a[2]}')
echo $ADDR_DEBOT > $DEBOT_ADDR

$TON_CLI --url $NETWORK deploy $DEBOT_TVC '{}' --abi $DEBOT_ABI --sign $DEBOT_KEYS --wc 0

DEBOT_ABI_DECODED=$(cat $DEBOT_ABI | xxd -ps -c 20000)
$TON_CLI --url $NETWORK call $ADDR_DEBOT setABI "{\"dabi\":\"$DEBOT_ABI_DECODED\"}" --sign $DEBOT_KEYS --abi $DEBOT_ABI

ICON_BYTES=$(base64 -w 0 $DEBOT_LOGO)
ICON=$(echo -n "data:image/png;base64,$ICON_BYTES" | xxd -ps -c 20000)
$TON_CLI --url $NETWORK call $ADDR_DEBOT setIcon "{\"icon\":\"$ICON\"}" --sign $DEBOT_KEYS --abi $DEBOT_ABI


