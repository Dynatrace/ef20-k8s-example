# Purpose of this repo

This repo contains guidelines on how to setup EF2.0  (ActiveGate + EEC + datasources - SNMP and Prometheus) on Kubernetes. It covers all components, provides example with 2 extensions and explains all the files.

# Setup steps overview

1. Download extension and activate them on cluster
2. Create docker images
3. Create tasks
4. Create k8s secrets and configs
5. Create k8s pod for ActiveGate + EEC
6. Create k8s pods for datasoures

# Steps

## Download extension

You have to download extensions by yourself. You also need to manually manage updates.

You can download extension from your tenant Environment v2 Extensions API - /extensions/{extensionName}/{extensionVersion} with accept header set to application/octet-stream.
You also need to activate extension you want to use on HUB. This will enable all the charts and metadata.

## Docker images

To run EF2.0 in your kubernetes cluster you will need following docker containers: ActiveGate, EEC and Datasources

### ActiveGate

ActiveGate image is avaialable for download from your tenant. You just need to create k8s secret to access docker registry

Instruction on how to use it are located at https://www.dynatrace.com/support/help/setup-and-configuration/setup-on-container-platforms/kubernetes/enable-kubernetes-api-monitoring/deploy-activegate-as-statefulset-kubernetes#expand--ag-monitoring-and-routing-yaml--3

### EEC and Datasources

EEC is component that is endpoint for datasources to get configurations and post metrics and statuses. 
Datasources are actual workers that use configuration provided by EEC. Currently in this example there are two datasources: SNMP and prometheus

To create those docker images you can run `buildimages.sh` script in `images` directory

## Create tasks

Task is a single extension configuration with unique identification for a datasource. Each configuration may have multiple devices configured. Since tasks contain confidential information (device adresses and authentication settings) they are stored as Kubernetes secret and are mounted as files.

To prepare setup you need to prepare folders for each extension (each folder has the same name as extension name), in which there should be extension.yaml and files for tasks.
Each task file is json file, you can check file defaults/taskTemplate.json how task file should look like. Most important fields are "id" and "userConfiguration". 
Each "id" value must be unique.
userConfiguration holds configuration provided to datasource. It has the same value as "value" object in configuration provided by REST API or Dynatrace HUB.

## Create k8s secrets and configs

### Secrets 

You need a secret that will be needed to connect ActiveGate to cluster - with key for ActiveGate token.

You will also need secret to access docker repository on Your tenant

Full documentation is available here: https://www.dynatrace.com/support/help/setup-and-configuration/setup-on-container-platforms/kubernetes/enable-kubernetes-api-monitoring/deploy-activegate-as-statefulset-kubernetes#deploy-activegate
To create secrets you have to run:

```
kubectl -n dynatrace create secret docker-registry dynatrace-docker-registry --docker-server=<YOUR_ENVIRONMENT_URL> --docker-username=<YOUR_ENVIRONMENT_ID> --docker-password=<YOUR_PAAS_TOKEN>
kubectl -n dynatrace create secret generic dynatrace-tokens --from-literal=auth-token=<YOUR_AUTH_TOKEN>
```

### Configs

There is one config file that is used by EEC, it's provided in defaults/runtimeConfiguration. To create it run:

```
kubectl create configmap runtime-configuration --from-file=defaults/runtimeConfiguration
```

## Create k8s pod and service for ActiveGate and EEC

Currently ActiveGate and EEC run in the same pod, sharing configuration files. 

### ActiveGate container

ActiveGate

ActiveGate image uses following environment variables:

 - DT_CAPABILITIES - should be set to `extension_controller`
 - DT_SERVER - should be set to your dynatrace server address
 - DT_TENANT - should have tenant name

ActiveGate image uses following mounts:

 - eec-ag-token - to share authentication token with EEC. It it should be mount to `/var/lib/dynatrace/gateway/config`
 - ag-secrets - secret with agtoken token and dttoken. It should be mount to `/var/lib/dynatrace/secrets/tokens/`. For more info 


### EEC container

EEC image uses following environment variables:

 - EecTokenPath - path to token file generated by ActiveGate
 - ServerUrl - address to endpoint exposed by ActiveGate. Should be set to 127.0.0.1:9999
 - TenantId - should be read from ConfigMap config, key tenant


EEC uses following volume mounts:

 - eec-ag-token - to share authentication token between ActiveGate and EEC (see EecTokenPath environment variable) 
 - dsargs - not used for this implementation, but required - mount at /mnt/dsexecargs
 - dstoken-volume - to share authentication token between EEC and datasource pods. Mount at `/var/lib/dynatrace/remotepluginmodule/agent/runtime/datasources`
 - runtime-configuration - for EEC runtimeConfiguration file, should be mounted at `/var/lib/dynatrace/remotepluginmodule/agent/conf/runtime`
 - extension mounts. Each mount has name matching extension (i.e. extension-generic-cisco for com.dynatrace.extension.snmp-generic-cisco-device) and mount approperiate secret in `/var/lib/dynatrace/remotepluginmodule/agent/config/extensions`, for example `/var/lib/dynatrace/remotepluginmodule/agent/config/extensions/com.dynatrace.extension.snmp-generic-cisco-device` should contain extension.yaml for generic cisco extension and all task files for this extension

There should also be service exposing EEC to other pods - by default EEC listens to port 14599

## Create k8s pods for datasources

Each datasource pod handles one configuration with unique ID. It requires following environment variables:

 - ConfigId - unique value corresponding with id provided in task file
 - EECPort - port used by EEC service
 - EECService - address used by EEC service
 - ProbeServerPort 

# Example

In example folder there are k8s yaml files with configs, secrets and example deployment monitoring 2 SNMP devices - cisco and palo alto as well as RabbitMQ Prometheus extension.

## Helper scripts

`rebuild_configs.sh` script that recreates all secrets and configs.

## Secrets and configs

Modify files agsecrets.yaml and config.yaml with proper values.

It's also necessary that you have secrets: 
 - `dynatrace-docker-registry ` to access Dynatrace docker registry (https://www.dynatrace.com/support/help/setup-and-configuration/setup-on-container-platforms/kubernetes/enable-kubernetes-api-monitoring/deploy-activegate-as-statefulset-kubernetes#deploy-activegate)
 - `regcred` so k8s can access Your docker registry where you've put your docker images


## Extensions 

All extensions are stored in extensions folder, each extension has it's own folder. In both generic cisco and palo alto there is one activation.json file. Modify them with addresses and credentials for your devices.

## Persistent Volume Claims

There is one Persistent volume claim file - pvc.yaml, using Azure file.csi.azure.com

## Kubernetes configuration.

In k8s.yaml there is full example configuration of running setup with 2 SNMP datasources and one prometheus. To adjust the setup you have to modify container images used in this example:

 - ActiveGate - from <YOUR_ENVIRONMENT_URL>/linux/activegate to actual environment url
 - EEC and Datasources from <YOUR_DOCKER_REGISTRY> to docker registry used to stored container images. Remember you will need `regcred` secret with credentials to this repo


