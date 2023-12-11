#!/bin/bash
#
CA_NAME=ca0
openssl req -x509 -config phree-openssl-${CA_NAME}.cnf \
  -days 36500 \
  -newkey rsa:4096 -sha256 \
  -out phree_${CA_NAME}_crt.pem -outform PEM
