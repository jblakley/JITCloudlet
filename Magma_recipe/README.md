# A Magma Deployment Recipe

While the JIT Cloudlet Recipe deploys the full JIT Cloudlet solution, this recipe deploys a standalone Magma AGW, Orc8r, and connecting it to a gNB and UE. This recipe also focuses on a 5G deployment rather than the LTE deployment used in the JIT Cloudlet Recipe.

DISCLAIMER: As with many deployment recipes, successful execution of the recipe is dependent on adjusting it to the specifics of a given environment. There is no guarantee this recipe can work "out of the box" in an arbitrary environment. Familiarity with Linux, Kubernetes, Helm, Docker, Magma, IP Networking, and Ansible are likely to be needed to assure successful completion.

The recipe consists of the following primary steps:

1. Bootstrapping the initial environment
2. Deploy the Management System
3. Deploy the Cloudlet
4. Connect a Phone a.k.a. UE
5. Validate the base platform



## Preparing your environment

You will need two physical systems (the **Magma Orchestrator (Orc8r)** system and the **Magma Access Gateway (AGW)** system both running Ubuntu 20.04. The AGW requires two physical ethernet network interface cards.

## Magma Deployment Paradigm
This recipe assumes a bare metal install of the Orc8r and AGW. The Orc8r deployment will deploy a kubernetes (k8s) cluster on the bare metal Or8r and the Orc8r services in the cluster. The AGW deployment uses docker and docker-compose deployment on the baremetal AGW system.

This recipe deploys a 5G network using Magma v1.9.

Clone this repository to both the Orc8r system and the AGW System. Set the environment variable `RECIPE_HOME` to the full pathname of the recipe folder (e.g,. `export RECIPE_HOME=/home/ubuntu/<repository>/recipe`).


## Deploy the Orc8r (TBD)
The Magma Orchestrator (Orc8r) --  must be deployed before the AGW can be fully deployed. Deployment of the AGW requires access to the Orc8r's rootCA.pem and the AGW's control proxy must be configured with the Orc8r domain name when the AGW is deployed. Note a single orc8r can server multiple AGW across 4G and 5G networks.

### Prerequisites
Ubuntu 20.04 system with >100GB disk.

### Deploying the Orc8r
This is the most straightforward guide for deploying the 1.8 Orc8r: [Magma-Galaxy Ansible Deployment](https://github.com/ShubhamTatvamasi/magma-galaxy)

A more DIY guide is here: [Install Orchestrator with Ansible](https://github.com/magma/magma/tree/master/orc8r/cloud/deploy/bare-metal-ansible)

Follow the directions in [Magma-Galaxy Ansible Deployment](https://github.com/ShubhamTatvamasi/magma-galaxy)

When finished, collect your certificate from `/home/magma/magma-galaxy/secrets/rootCA.pem`. You need this to connect AGWs.

To connect to the NMS console, you will also need  `/home/magma/magma-galaxy/secrets/admin_operator.pfx`. The password for the certificate is 'password'.

### Validating the setup
Connect to NMS as described in the above guides. If you are unable to connect to NMS, then check that the orc8r kubernetes pods are running cleanly.

## Deploy the AGW
Deployment of the cloudlet involves:

1. Configuring deployment specific environment variables and installing prerequisites (`.env`, `bootstrap.sh`, reboot)
2. Setting up the AGW network configuration  (`agwc-networking` playbook)
3. AGW docker-compose deployment (`agwc1` playbook, reboot, `agcw2` playbook)

### Initial configuration and installation of prerequistes

```
$ export RECIPE_HOME=<THIS DIRECTORY>
$ cd $RECIPE_HOME/bootstrap
$ cp template.env .env
$ vim .env
```

Edit the variables in .env to your preferred values. Then run:

```
$ bash bootstrap.sh
```

Reboot and test that docker works correctly (e.g., `docker ps` should respond with no containers running). You may want to to inspect the `$RECIPE_HOME/ansible/hosts.yml` file to validate the configuration set up by `bootstrap.sh`.

`bootstrap.sh` runs an ansible playbook called `deploy-common-system.yml`. If you run into issues with during this phase, you may need rerun this playbook.

### AGW network configuration

This will set up the AGW eth0 and eth1 interfaces

```
$ cd $RECIPE_HOME/ansible
$ ansible-playbook deploy-agwc-networking.yml -K
$ ip a
```
Verify that network for eth0 and eth1 are correct. You should be able to ping the management system and the router over eth0 and the eNB over eth1.

### AGW docker-compose deployment (Part 1 and Part 2)

The docker-compose version of the AGW will be deployed in two stages.

Stage one sets up many of the agwc parameters and files and runs `agw_install_docker.sh`. This script clones magma and configures it for use. It installs the OpenVSwitch used by magma which requires a reboot.

```
$ cd $RECIPE_HOME/ansible
$ ansible-playbook deploy-agwc1.yml -K
```
Reboot.

Stage two completes the configuration and brings up the AGW containers. After this is complete.

```
$ cd $RECIPE_HOME/ansible
$ ansible-playbook deploy-agwc2.yml -K
$ docker ps
```

All AGW should be running and showing healthy. The playbook will print the information needed to provision the AGW in the Orc8r. You can do that provisioning at this point.

At this point, you should have a working dockerized AGW.

### Connect the Orc8r and AGW

If you haven't already done so, you should provision the AGW in the Orc8r. Get the AGW configuration data with:

```
$ MAGMADPOD=$(kubectl get pods --namespace magma -l app.kubernetes.io/component=magmad -o json|jq -r '.items[].metadata.name')
$ kubectl exec -it ${MAGMADPOD} --namespace magma -- show_gateway_info.py
```

## Connect a Phone a.k.a. UE

## Validate the base platform


## Demonstrate the protoype

## Other tools, tips, debugging suggestions




# Notes to be dealt with later

## Set up ansible
```
# Can this be part of playbook TODO
cd git/kubernetes
# Can these be part of requirements.yml TODO
ansible-galaxy collection install community.kubernetes
ansible-galaxy collection install cloud.common
ansible-galaxy collection install -r collections/requirements.yml
```

Do this:
https://askubuntu.com/questions/1376119/ubuntu-20-04-nic-naming-and-match-mac-with-netplan
https://askubuntu.com/questions/1255823/network-interface-names-change-every-reboot
```
Your /etc/default/grub is incorrect.

sudo vim /etc/default/grub

# GRUB_CMDLINE_LINUX="net.ifnames=0 biosdevname=0"
GRUB_CMDLINE_LINUX=""
sudo update-grub

reboot
```


# TODO

