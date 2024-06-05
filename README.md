# The Just-In-Time (JIT) Cloudlet

The Just-In-Time Cloudlet as described in the CMU Technical Report, *[The Just-In-Time Cloudlet](http://reports-archive.adm.cs.cmu.edu/anon/2023/abstracts/23-138.html)*, provides an integrated platform built on cloud-native open-source software and COTS hardware. The technical report provides a reference architecture and the details of a prototype implementation to demonstrate the concept and the architecture. Construction of the prototype required substantial system and deployment integration effort. This repository provider the primary software required to implement your own version of that prototype.

The JIT Cloudlet Reference Architecture is shown below.
![Reference_Architecture](https://github.com/jblakley/CMUProjects/assets/6760112/4ae93c2a-d3f5-4e0e-88ad-ffaafed2e76f)

Deployment of the prototype is primarily accomplished using an ansible, docker-compose, helm based recipe executed on a fresh Ubuntu system. To use this recipe:

```
cd ./recipe
```

and open the README

