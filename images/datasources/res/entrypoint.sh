#!/bin/sh
set -o errexit -o noclobber -o nounset

DsInstallDir="/opt/dynatrace/remotepluginmodule/agent/datasources"
DsTokenPath="/var/lib/dynatrace/remotepluginmodule/agent/runtime/datasources/dsauthtoken"

EECService="${EECService:?Missing EECService}"
EECPort="${EECPort:?Missing EECPort}"
ConfigId="${ConfigId:?Missing ConfigId}"
DSType="${Type:?Missing Type}"

echo "*** Waiting for token file $DsTokenPath..."
until [ -e "$DsTokenPath" ]; do
    echo "." && sleep 5s
done && echo

case $DSType in 
  SNMP)
  DSPath="$DsInstallDir/snmp/dynatracesourcesnmp"
  break
  ;;
  prometheus)
  DSPath="$DsInstallDir/prometheus/dynatracesourceprometheus"  
  break
  ;;
  *)
  echo -e "Unknown type: ${DSType}, possible options are SNMP and prometheus"
esac

echo "*** Starting Snmp with EECService: $EECService EECPort $EECPort ConfigId $ConfigId"

# shellcheck disable=SC2086
"$DSPath" \
  --probeserverport="$ProbeServerPort" \
  --logtoconsole \
  --url=$EECService:$EECPort \
  --dsid=${ConfigId} \
  --idtoken=$DsTokenPath