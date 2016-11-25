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
Modify docker-compose.override.yml to map your local WoW 3.3.5 client directory for map extraction.  NOTE: This step needs permissions to create directories/files in your wow client directory that you map into the container for map extraction.

><pre>version: '2'
>services:
>  worldserver:
>    -volumes **/path to your WoW 3.3.5 install/**:/opt/trinitycore/data

Modify 05_admin_account.sql if you want to change the default GM account that is created and/or the realm IP address.

Then run:
```bash
make install
```

This will create the database, create the config files, build TrinityCore, extract the map files from your client, and finally bring up the server.  This make take several hours.

### Running:
To bring up the server:
```
make up
```
To bring down the server:
```
make down
```

### Using:
During installation a default GM account is created.  Unless you changed the username/password, the default is trinity/trinity.  This account is a an admin account and can be used to create other accounts.

To login to the remote console:
```
telnet 127.0.0.1 3443

Trying 127.0.0.1...
Connected to 127.0.0.1.
Escape character is '^]'.
Authentication Required
Username: trinity
Password: trinity
Welcome to a Trinity Core server.
TC>
```
You can use the remote console to create additional accounts with:
```
TC>account create USERNAME PASSWORD
```
