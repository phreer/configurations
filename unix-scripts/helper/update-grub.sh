#!/bin/bash
# Update grub config. This is used in distributions without native update-grub command.

# An alternative
# grub2-mkconfig -o "$(readlink -e /etc/grub2.conf)"

grub2-mkconfig -o /boot/grub2/grub.cfg

