#!/bin/bash

#set -x

if [ ! $# == 1 ];then
   echo "ERROR: send contract name"
   exit 1
fi

CONTRACT_NAME=$1

$TON_COMPILER $CONTRACT_NAME.sol
$TVM_LINKER compile $CONTRACT_NAME.code --lib $TVM_LINKER_STDLIB -o $CONTRACT_NAME.tvc

CONTRACT_DECODED=$($TVM_LINKER decode --tvc $CONTRACT_NAME.tvc | grep "code:" | awk '{split($0,a,": "); print a[2]}')

echo $CONTRACT_DECODED > $CONTRACT_NAME.decoded

CONTRACT_HASH=$($TVM_LINKER decode --tvc $CONTRACT_NAME.tvc | grep "code_hash:" | awk '{split($0,a,": "); print a[2]}')

echo $CONTRACT_HASH > $CONTRACT_NAME.hash
