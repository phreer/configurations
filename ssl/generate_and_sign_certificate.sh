#!/bin/bash

SERVER_NAME=$1

function usage() {
  echo "usage: $0 <server_name>"
}

if [ -z "$SERVER_NAME" ]; then
  usage >&2
  exit 1
fi

echo "Generating request..."
./generate_request.sh $SERVER_NAME
echo "Request generated"


echo "Signing certificate..."
./sign.sh $SERVER_NAME
echo "Certificcate signed"
