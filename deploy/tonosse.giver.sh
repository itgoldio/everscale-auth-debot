#!/bin/bash

. ../env.sh

$TON_CLI --url $NETWORK call $TON_TONOSSE_GIVER_ADDR sendTransaction '{"dest":"'$1'", "value":3000000000, "bounce":false}' --abi $TON_TONOSSE_GIVER_ABI --sign $TON_TONOSSE_GIVER_KEY
