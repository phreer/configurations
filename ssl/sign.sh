#!/bin/bash

CA_NAME=ca0
SERVER_NAME=$1

function usage() {
  echo "usage: $0 <server_name>"
}

if [ -z "$SERVER_NAME" ]; then
  usage >&2
  exit 1
fi

openssl ca -config phree-openssl-${CA_NAME}.cnf \
  -policy signing_policy -extensions signing_req \
  -out phree_${SERVER_NAME}_crt.pem \
  -infiles phree_${SERVER_NAME}_csr.pem
