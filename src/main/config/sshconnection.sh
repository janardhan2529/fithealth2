#!/bin/bash
host=$(cat /u01/jenkins/workspace/fithealth/src/main/config/ansible/hosts)
echo "$host"

ssh -o StrictHostKeyChecking=no -i /u01/jenkins/workspace/fithealth/src/main/terraform/global/keys/jana ubuntu@$host "ANSIBLE_HOST_KEY_CHECKING=false ansible-playbook --private-key ~/.ssh/jana -i /tmp/hosts /tmp/java-playbook.yml"
