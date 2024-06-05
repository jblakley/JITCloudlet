# A Just-In-Time Cloudlet Recipe

The Just-In-Time Cloudlet as described in the CMU Technical Report, *[The Just-In-Time Cloudlet](http://reports-archive.adm.cs.cmu.edu/anon/2023/abstracts/23-138.html)*, provides an integrated platform built on cloud-native open-source software and COTS hardware. The technical report provides a reference architecture and the details of a prototype implementation to demonstrate the concept and the architecture. Construction of the prototype required substantial system and deployment integration effort. The purpose of this recipe is to make it easier for those who want to replicate that prototype. Since the report describes the hardware and physical configuration of the prototype, this recipe focuses on the software deployment.

DISCLAIMER: As with many deployment recipes, successful execution of the recipe is dependent on adjusting it to the specifics of a given environment. There is no guarantee this recipe can work "out of the box" in an arbitrary environment. Familiarity with Linux, Kubernetes, Helm, Docker, Magma, IP Networking, and Ansible are likely to be needed to assure successful completion.

The recipe consists of the following primary steps:

1. Bootstrapping the initial environment
2. Deploy the Management System
3. Deploy the Cloudlet
4. Connect a Phone a.k.a. UE
5. Validate the base platform
6. Deploy the sample edge-native applications
7. Demonstrate the protoype

The JIT Cloudlet Reference Architecture is shown below.
![Reference_Architecture](https://github.com/jblakley/CMUProjects/assets/6760112/4ae93c2a-d3f5-4e0e-88ad-ffaafed2e76f)

## Preparing your environment

You will need two physical systems (the **management system** and the **cloudlet**) running Ubuntu 20.04. The cloudlet requires two physical ethernet network interface cards to support the Magma Access Gateway (AGW). The specific systems used in the prototype are provided in the tech report. The prototype used an x86-based laptop to run the Orc8r and an ARM-based desktop server to act as the cloudlet. As of this publication, the laptop must be x86 while the cloudlet can be either x86 or ARM. You will also need a small router and switch as shown in the reference architecture. Final connnectivity and functionality testing will require a smartphone and an ability to create a SIM for the Magma network.

Connect the environment as shown in the diagram. Specific network configuration will be done later but it is good to validate connectivity between the systems at this point.

Clone this repository to both the management system and the cloudlet. Set the environment variable `RECIPE_HOME` to the full pathname of the recipe folder (e.g,. `export RECIPE_HOME=/home/ubuntu/<repository>/recipe`).

## Deploy the Management System (TBD)
The management system -- at least the Magma Orchestrator (Orc8r) component --  must be deployed before the cloudlet can be fully deployed. Deployment of the cloudlet's AGW requires access to the Orc8r's rootCA.pem and the AGW's control proxy must be configured with the Orc8r domain name when the AGW is deployed.

### Prerequisites

### Deploying the Orc8r

### Other Management Systems

### Validating the setup

## Deploy the Cloudlet
The Cloudlet runs the Magma AGW and the sample edge-native applications. In the end state, all run within a single kubernetes cluster. However, the AGW is first deployed using docker-compose and then transitioned into the kubernetes cluster. So, deployment of the cloudlet involves:

1. Configuring deployment specific environment variables and installing prerequisites (`.env`, `bootstrap.sh`, reboot)
2. Setting up the AGW network configuration  (`agwc-networking` playbook)
3. AGW docker-compose deployment (`agwc1` playbook, reboot, `agcw2` playbook)
4. Kubernetes deployment (`kubernetes` playbook)
5. AGW deployment on kubernetes (`agwc-k8s` playbook)
6. Edge application deployment on kubernetes (`edgeapps` playbook)

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

### Kubernetes deployment
This step deploys a kubernetes cluster that will run both the AGW and the EdgeApps.

```
$ ansible-playbook deploy-kubernetes.yml -K
$ k9s
```

The `k9s` program is a useful command line tool for monitoring kubernetes clusters. You should see each of the `kube-system` pods successfully deploying. `kubectl get pods --all-namespaces` can also be used at this point.

### AGW deployment on kubernetes

This step takes down the docker-compose AGW and restarts it within the kubernetes cluster in the `magma` namespace. The helm charts in `$RECIPE_HOME/charts/agwc` do the actual deployment.

```
$ ansible-playbook deploy-agwc-k8s.yml -K
$ k9s
```

You should see the magma pods starting successfully.

### Connect the Orc8r and AGW

If you haven't already done so, you should provision the AGW in the Orc8r. Get the AGW configuration data with:

```
$ MAGMADPOD=$(kubectl get pods --namespace magma -l app.kubernetes.io/component=magmad -o json|jq -r '.items[].metadata.name')
$ kubectl exec -it ${MAGMADPOD} --namespace magma -- show_gateway_info.py
```

## Deploy the sample edge-native applications
You can now deploy the sample edge-native applications (`openscout` and `openrtist`) at this point. The helm charts in `$RECIPE_HOME/charts` do the actual deployment.

```
$ ansible-playbook deploy-edgeapps.yml -K
$ k9s
```

You should see the application pods starting successfully in their own namespaces.

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

getting variables (e.g., container repositories, tags through bootstrap to ansible to helm)