#!/bin/bash
host=$(cat /u01/jenkins/workspace/fithealth/src/main/config/ansible/hosts)
echo "$host"
sudo chmod 600 /u01/jenkins/workspace/fithealth/src/main/terraform/global/keys/jana
scp -i /u01/jenkins/workspace/fithealth/src/main/terraform/global/keys/jana /u01/jenkins/workspace/fithealth/target/fithealth2.war ubuntu@$host:/tmp/
ssh -o StrictHostKeyChecking=no -i /u01/jenkins/workspace/fithealth/src/main/terraform/global/keys/jana ubuntu@$host "ANSIBLE_HOST_KEY_CHECKING=false ansible-playbook --private-key ~/.ssh/jana -i /tmp/hosts /tmp/deploy.yml"
