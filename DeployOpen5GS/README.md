# A quick recipe to deploy Open5GSCore as an alternative to the Magma 5G core

## Bootstrapping

```
cd bootstrap
cp template.env .env
# Edit .env to your required values
bash bootstrap.sh
```
It the `deploy-common-system.yml` playbook completes successfully:

```
cd ../ansible
ansible-playbook deploy-open5gs.yml -K
```
