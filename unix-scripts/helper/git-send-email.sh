#!/bin/bash
#
proxychains -f ~/proxychains.conf git send-email $@
