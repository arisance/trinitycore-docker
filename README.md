# trinitycore-docker
This is a docker setup for running [Trinity Core 3.3.5a](https://github.com/TrinityCore/TrinityCore/tree/3.3.5)

You can use this project to build and run a Trinity Core server.

## Installation
### Prerequistes:
* docker 1.12.0+
* docker-compose 1.9.0+
* GNU make 4.1+
* p7zip
* wget 1.17.1+
* curl 7.49.0+

### Installing:
Create docker-compose-override.yml with the following

```
version: '2'
services:
  worldserver:
    -volumes <path to your WoW 3.3.5 install>:/opt/trinitycore/data
```
Then run:
```bash
make install
```
