# A Magma Deployment Recipe

While the JIT Cloudlet Recipe deploys the full JIT Cloudlet solution, this recipe deploys a standalone Magma AGW, Orc8r, and connecting it to a gNB and UE. This recipe also focuses on a 5G deployment rather than the LTE deployment used in the JIT Cloudlet Recipe.

DISCLAIMER: As with many deployment recipes, successful execution of the recipe is dependent on adjusting it to the specifics of a given environment. There is no guarantee this recipe can work "out of the box" in an arbitrary environment. Familiarity with Linux, Docker, Magma, IP Networking, and Ansible are likely to be needed to assure successful completion. As compared with the [JITC_recipe](../JITC_recipe), this recipe does not:

- Deploy the AGW in Kubernetes. It uses docker-compose to deploy the AGW containers.
- Include connecting a gNB or UE to the network.

The recipe consists of the following primary steps:

1. Bootstrapping the initial environment
2. Deploy the Orchestrator
3. Deploy the Access Gateway
4. Connect the AGW to the Orc8r
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
This is the most straightforward guide for deploying the 1.8 Orc8r. It works with Magma 1.9 AGW and will presumably be upgraded for 1.9 eventually: [Magma-Galaxy Ansible Deployment](https://github.com/jblakley/magma-galaxy)

A more DIY guide is here: [Install Orchestrator with Ansible](https://github.com/magma/magma/tree/master/orc8r/cloud/deploy/bare-metal-ansible)

Follow the directions in [Magma-Galaxy Ansible Deployment](https://github.com/jblakley/magma-galaxy)

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
#### Notes on the `.env` variables:
- MAGMA_DN is the domain for your Orc8r
- PRIVATE_KEY is used for ansible hosts
- ROOT_CA_PATH  is the directory that contains your Orc8r's `rootCA.pem`
- At this writing:
  - `DOCKER_IMAGE_VERSION=20.10.21-0ubuntu1~20.04.2`
  - `DOCKER_COMPOSE_VERSION="v2.17.2"`

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

#### Notes on network configuration
- Your network renderer should be set to `NetworkManager` (check: `/etc/netplan/00-installer-config.yaml`)
- You may have issues with connectivity if this stage fails. Try to have direct console access during this playbook's execution

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

All AGW containers should be running and showing healthy. The playbook will print the information needed to provision the AGW in the Orc8r. You can do that provisioning at this point. If you lose the info:

```
$ docker exec magmad show_gateway_info.py
```
Use this to connect the AGW to the Orc8r

## Validate the base platform
At this point, you should have a working dockerized AGW.

## Other tools, tips, debugging suggestions




# Notes to be dealt with later

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

