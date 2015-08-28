#!/bin/bash
#
# Quick script to verify syntax before running. All CLI args are passed to the 'ansible-playbook' command
# Assumes:
# - Inventory is located in ./hosts

ansible-playbook site.yml -i hosts $@
