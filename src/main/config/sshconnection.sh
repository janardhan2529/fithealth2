#!/bin/bash
host=$(cat hosts)
echo "$host"
ssh -o StrictHostKeyChecking=no -i ~/.ssh/jana ubuntu@$host
"ANSIBLE_HOST_KEY_CHECKING=false ansible-playbook --private-key ~/.ssh/jana -i /tmp/hosts /tmp/java-playbook.yml"