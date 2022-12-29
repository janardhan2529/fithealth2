#!/bin/bash
host=$(cat hosts)
echo "$host"
scp -i /u01/jenkins/workspace/fithealth/src/main/terraform/global/keys/jana /u01/jenkins/workspace/fithealth/target/fithealth2.war ubuntu@$host:/tmp/
ssh -o StrictHostKeyChecking=no -i ~/.ssh/jana ubuntu@$host "ANSIBLE_HOST_KEY_CHECKING=false ansible-playbook --private-key ~/.ssh/jana -i /tmp/hosts /tmp/deploy.yml"
