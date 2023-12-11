#!/bin/bash

SERVER_NAME=$1

function usage() {
  echo "usage: $0 <server_name>"
}

if [ -z "$SERVER_NAME" ]; then
  usage >&2
  exit 1
fi

SSL_CONFIG_PATH=$(mktemp)

sed -e "3 s/__SERVER_NAME__/${SERVER_NAME}/" phree-openssl-server.cnf > ${SSL_CONFIG_PATH}
openssl req -config ${SSL_CONFIG_PATH} \
  -newkey rsa:2048 -sha256 -nodes \
  -days 36500 \
  -out phree_${SERVER_NAME}_csr.pem -outform PEM
