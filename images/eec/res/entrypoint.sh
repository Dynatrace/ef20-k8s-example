#!/bin/bash
set -o errexit -o pipefail -o noclobber -o nounset

# Silence shellcheck warnings
TenantId="${TenantId:?Missing TenantId}"
ServerUrl="${ServerUrl:?Missing ServerUrl}"
EecTokenPath="${EecTokenPath:?Missing EecTokenPath}"
EecIngestPort="${EecIngestPort:?Missing EecIngestPort}"
ExtensionsConfPath="${ExtensionsConfPath:?Missing ExtensionsConfPath}"
ExtensionsModuleExecPath="${ExtensionsModuleExecPath:?Missing ExtensionsModuleExecPath}"
DsProcessArgsDir="${DsProcessArgsDir:?Missing DsProcessArgsDir}"
DsInstallDir="${DsInstallDir:?Missing DsInstallDir}"

set -a
# shellcheck disable=SC2034
DT_EEC_REST_SERVER_HOST_IP="0.0.0.0"
set +a

echo "*** Using tenant $TenantId, server URL $ServerUrl"

{ 
echo "TokenFilePath ${EecTokenPath}" 
echo "k8s.process_args_dir=${DsProcessArgsDir}"
echo "Server $ServerUrl"
echo "Tenant $TenantId"
echo "IngestPort=$EecIngestPort"
} >> "$ExtensionsConfPath"

echo "*** Contents of '$ExtensionsConfPath':"
cat "$ExtensionsConfPath"
echo

echo "*** Waiting for eec.token file at $EecTokenPath..."
until [ -e "${EecTokenPath}" ]; do
    sleep 5s
done

echo "*** Starting extensionsmodule..."
"$ExtensionsModuleExecPath" "k8s"
