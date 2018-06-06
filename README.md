[![Docker Stars](https://img.shields.io/docker/stars/_/ubuntu.svg)](https://hub.docker.com/r/equivalent/azure-test/)


# Azure Appservices docker test

This is simple docker image for testing Azure setup on "Azure App Serices" for "Doker Containers".
This container is built in Ruby language using lightweight web lib
"Sinatra".

`curl https://my-application.azurewebsites.net/`

It can also tests Postgresql connection using lightweight gem "sequel"

> no ENVironment variables needed on Azure server

`curl https://my-application.azurewebsites.net/db`

> ENVironment variables PG_USER, PG_PASS, PG_HOST need to be set ! See
> docker-compose example files

## Create Docker App Service

```
Azure web portal -> Add New App Service -> search for word "container" -> Web App for Containers -> Create -> 

app name: my-application
subscription: up to you 
resource-group: up to you 
configure container:
  single container:
    image source: Docker hub
    repository access: public
    image:  equivalent/azure-test:latest
```

Later on we can change this to private ACR (private amazon registry)


## Buliding changes

Think about this project as a "scaffold application" to test if docker
container is able to render simple message.

```
cp docker-compose.ACR.example.yml docker-compose.yml

vim docker-compose.yml  # do your changes. docker-compose.yml is ".gitignored"


docker-compose build
docker-compose up
docker-compose push
```


## Setting Enviroment variables on App Services

```
MyAppServiceName > Application Settings 
```

whatever you add to the "Application settings" will end up as enviroment
variables in docker container

## Docker compose setup (multicontainer)

I'm personally testing this only for single container purpose but in
principle this should work 

in:

```
MyAppServiceName > Continer Settings
```

upload a config file `docker-compose.publicDockerHub.example.yml` in this repo or if you want
to create one from scratch:


```
version: '3'
services:
  web:
    image: "equivalent/azure-test:latest"
    build:
      context: ./
      dockerfile: Dockerfile
    ports:
     - "80:80"
     - "2222:2222"

```


### azure acr


use the `docker-compose.ACR.example.yml`

in order to pull & push images to Azure ACR you need to login via `az`
cli:

```
az acr login --name registryname
```


now you can `docker-compose build && docker-compose push`

or if you have problems with `docker-compose` not recognizing
credentials manual push `docker push registryname.azurecr.io/azure-test:latest`


## Restart build / reload docker containers

```
MyAppServiceName > Continer Settings 
```

at the bottom in section "Continuous Deployment" show more on WEBHOOK URL

all you need to do is curl this link to reload docker image:


`curl -X POST 'https://$my-app-service-name:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx@my-app-service-name.scm.azurewebsites.net/docker/hook' -H '' -d ''`


**note !!**

what you can do is that you can configure your ACR registry to call this
webhook on a push.

For example if you push to your `myregistry.azurecr.io/my-project-repo:latest` it will trigger this
webhook => reloading the server

```
container registry > myregistry > webhooks > Add 

name: anything
service_uri: https://$my-app-service-name:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx@my-app-service-name.scm.azurewebsites.net/docker/hook
action: push
scope:  my-project-repo:latest
```

* https://docs.microsoft.com/en-us/azure/app-service/containers/app-service-linux-ci-cd

## ssh

https://docs.microsoft.com/en-us/azure/app-service/containers/app-service-linux-ssh-support

look at `Dockerfile` the ssh part is important + the startup script
`runs.sh`

you cas ssh via web interface (Azure portal)

```
app services > myappilation > ssh
```

## Logging

you can find server logs here:

```
app services > myappilation > container settings 

section Loggs
```

In order to enable full logs (docker logs) you need to do:


```
app services > myappilation > diagnostics logs > docker container loggs > set to FileSystem
```

this will ensure logs are beeing captured

## Testing Postgresql connection


Set the  ENVironment variables PG_USER, PG_PASS, PG_HOST (how? look at section "Setting Enviroment variables on App Serviece")


Then make sure you have `Allow access to Azure services` set to `on` in
`Azure database for postgres > my-database > Sonnection Settings`


now you should be able to:

`curl https://my-application.azurewebsites.net/db`

Error means it don't work, `Conection Success` mean it works !


## Versions

```
equivalent/azure-test:latest       2018-06-06
equivalent/azure-test:v1           2018-06-06
`''
