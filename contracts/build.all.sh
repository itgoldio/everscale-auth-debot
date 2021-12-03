#!/bin/bash

. ../env.sh

contracts=("AuthDebot")

for i in ${!contracts[*]}
do
  cd ${contracts[$i]} 
  . ../build.contract.sh ${contracts[$i]}
  cd -
done
