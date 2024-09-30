# Deploy Magma Orchestrator

Quick Install:
```bash
sudo bash -c "$(curl -sL https://github.com/jblakley/Magma_recipe/magma-galaxy/raw/master/deploy-orc8r.sh)"
```

Switch to `magma` user after deployment has finsished:
```bash
sudo su - magma
```

Once all pods are ready, setup NMS login:
```bash
cd $RECIPE_HOME/magma-galaxy
ansible-playbook config-orc8r.yml
```

You can get your `rootCA.pem` file from the following location:
```bash
cat $RECIPE_HOME/magma-galaxy/secrets/rootCA.pem
```
