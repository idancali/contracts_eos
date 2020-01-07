#!/bin/bash
source ./scripts/deploy/common.conf

function cleos() { command cleos --verbose --url=${NODEOS_LOCATION} --wallet-url=$WALLET_URL "$@"; echo $@; }
on_exit(){
  echo -e "${CYAN}cleaning up temporary keosd process & artifacts${NC}";
  kill -9 $TEMP_KEOSD_PID &> /dev/null
  rm -r $WALLET_DIR
}
trap my_trap INT
trap my_trap SIGINT


# start temp keosd
rm -rf $WALLET_DIR
mkdir $WALLET_DIR
keosd --wallet-dir=$WALLET_DIR --unix-socket-path=$UNIX_SOCKET_ADDRESS &> /dev/null &
TEMP_KEOSD_PID=$!
sleep 1

# create temp wallet
cleos wallet create --file /tmp/.temp_keosd_pwd
PASSWORD=$(cat /tmp/.temp_keosd_pwd)
cleos wallet unlock --password="$PASSWORD"


# 1) Import user keys

echo -e "${CYAN}-----------------------CONTRACT / USER KEYS-----------------------${NC}"
cleos wallet import --private-key "$MASTER_PRV_KEY"
cleos wallet import --private-key "$MASTER_PRV_KEY"
cleos wallet import --private-key "$MASTER_PRV_KEY"
cleos wallet import --private-key "$MASTER_PRV_KEY"


# 2) Create accounts

cleos system newaccount eosio bntreporter4 $MASTER_PUB_KEY --stake-cpu "50 EOS" --stake-net "10 EOS" --buy-ram-kbytes 5000 --transfer

cleos system newaccount eosio bnttestuser1 $MASTER_PUB_KEY --stake-cpu "50 EOS" --stake-net "10 EOS" --buy-ram-kbytes 5000 --transfer
cleos system newaccount eosio bnttestuser2 $MASTER_PUB_KEY --stake-cpu "50 EOS" --stake-net "10 EOS" --buy-ram-kbytes 5000 --transfer
cleos system newaccount eosio fakeos $MASTER_PUB_KEY --stake-cpu "50 EOS" --stake-net "10 EOS" --buy-ram-kbytes 50000 --transfer

cleos system newaccount eosio bnt2syscnvrt $MASTER_PUB_KEY --stake-cpu "50 EOS" --stake-net "10 EOS" --buy-ram-kbytes 50000 --transfer
cleos system newaccount eosio bnt2sysrelay $MASTER_PUB_KEY --stake-cpu "50 EOS" --stake-net "10 EOS" --buy-ram-kbytes 50000 --transfer

cleos system newaccount eosio bnt2aaacnvrt $MASTER_PUB_KEY --stake-cpu "50 EOS" --stake-net "10 EOS" --buy-ram-kbytes 50000 --transfer
cleos system newaccount eosio bnt2aaarelay $MASTER_PUB_KEY --stake-cpu "50 EOS" --stake-net "10 EOS" --buy-ram-kbytes 50000 --transfer
cleos system newaccount eosio aaa $MASTER_PUB_KEY --stake-cpu "50 EOS" --stake-net "10 EOS" --buy-ram-kbytes 50000 --transfer

cleos system newaccount eosio bnt2bbbcnvrt $MASTER_PUB_KEY --stake-cpu "50 EOS" --stake-net "10 EOS" --buy-ram-kbytes 50000 --transfer
cleos system newaccount eosio bnt2bbbrelay $MASTER_PUB_KEY --stake-cpu "50 EOS" --stake-net "10 EOS" --buy-ram-kbytes 50000 --transfer
cleos system newaccount eosio bbb $MASTER_PUB_KEY --stake-cpu "50 EOS" --stake-net "10 EOS" --buy-ram-kbytes 50000 --transfer

# 3) Deploy contracts

echo -e "${CYAN}-----------------------DEPLOYING CONTRACTS-----------------------${NC}"
cleos set contract fakeos $EOSIO_CONTRACTS_ROOT/eosio.token/
cleos set contract aaa $EOSIO_CONTRACTS_ROOT/eosio.token/
cleos set contract bbb $EOSIO_CONTRACTS_ROOT/eosio.token/

cleos set contract bnt2syscnvrt $MY_CONTRACTS_BUILD/BancorConverter
cleos set contract bnt2aaacnvrt $MY_CONTRACTS_BUILD/BancorConverter
cleos set contract bnt2bbbcnvrt $MY_CONTRACTS_BUILD/BancorConverter

cleos set contract bnt2sysrelay $EOSIO_CONTRACTS_ROOT/eosio.token/ 
cleos set contract bnt2aaarelay $EOSIO_CONTRACTS_ROOT/eosio.token/ 
cleos set contract bnt2bbbrelay $EOSIO_CONTRACTS_ROOT/eosio.token/

# 4) Set Permissions

cleos set account permission bnt2syscnvrt active '{ "threshold": 1, "keys": [{ "key": "EOS8UAsFY4RacdaeuadicrkP66JQxPsbNyucmbT8Z4GjwFoytsK9u", "weight": 1 }], "accounts": [{ "permission": { "actor":"bnt2syscnvrt","permission":"eosio.code" }, "weight":1 }] }' owner -p bnt2syscnvrt
cleos set account permission bnt2sysrelay active '{ "threshold": 1, "keys": [{ "key": "EOS8UAsFY4RacdaeuadicrkP66JQxPsbNyucmbT8Z4GjwFoytsK9u", "weight": 1 }], "accounts": [{ "permission": { "actor":"bnt2sysrelay","permission":"eosio.code" }, "weight":1 }] }' owner -p bnt2sysrelay

cleos set account permission bnt2aaacnvrt active '{ "threshold": 1, "keys": [{ "key": "EOS8UAsFY4RacdaeuadicrkP66JQxPsbNyucmbT8Z4GjwFoytsK9u", "weight": 1 }], "accounts": [{ "permission": { "actor":"bnt2aaacnvrt","permission":"eosio.code" }, "weight":1 }] }' owner -p bnt2aaacnvrt
cleos set account permission bnt2aaarelay active '{ "threshold": 1, "keys": [{ "key": "EOS8UAsFY4RacdaeuadicrkP66JQxPsbNyucmbT8Z4GjwFoytsK9u", "weight": 1 }], "accounts": [{ "permission": { "actor":"bnt2aaarelay","permission":"eosio.code" }, "weight":1 }] }' owner -p bnt2aaarelay

cleos set account permission bnt2bbbcnvrt active '{ "threshold": 1, "keys": [{ "key": "EOS8UAsFY4RacdaeuadicrkP66JQxPsbNyucmbT8Z4GjwFoytsK9u", "weight": 1 }], "accounts": [{ "permission": { "actor":"bnt2bbbcnvrt","permission":"eosio.code" }, "weight":1 }] }' owner -p bnt2bbbcnvrt
cleos set account permission bnt2bbbrelay active '{ "threshold": 1, "keys": [{ "key": "EOS8UAsFY4RacdaeuadicrkP66JQxPsbNyucmbT8Z4GjwFoytsK9u", "weight": 1 }], "accounts": [{ "permission": { "actor":"bnt2bbbrelay","permission":"eosio.code" }, "weight":1 }] }' owner -p bnt2bbbrelay

./scripts/deploy/bancor_network.sh -u "$NODEOS_LOCATION" -w "$WALLET_URL"

on_exit
echo -e "${GREEN}--> Done${NC}"
