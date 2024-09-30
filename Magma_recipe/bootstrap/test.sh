#!/bin/bash
test -f .env || bash -c "echo No '.env file; exiting'"; test -f .env || exit
source .env
# env


if ! grep "ORC8R_IP" /etc/hosts
then
	sudo sed "s#<ORC8R_IP>#${ORC8R_IP}#;s#<CLOUDLET_DN>#${CLOUDLET_DN}#" ../files/etchosts.template >> ../tmp/etchosts
fi

echo ${PLAYBOOK_HOME}
cd ${PLAYBOOK_HOME}

# ANSIBLE: Run common-system playbook
#ansible-playbook deploy-common-system.yml -K -vv $*
#ansible-playbook remove-kubernetes.yml -K -vv $*
# ansible-playbook deploy-agwc.yml -K -vv $*