FROM registry.access.redhat.com/ubi8/ubi-minimal:8.6

ENV SnmpExecArgsPath="/mnt/dsexecargs/snmp.process.json"
ENV DsInstallDir="/opt/dynatrace/remotepluginmodule/agent/datasources"
ENV DsLogFile="/var/lib/dynatrace/remotepluginmodule/log/extensions/datasources/dynatracesourcesnmp.log"


RUN mkdir -p "$DsInstallDir/snmp"  && mkdir -p "$DsInstallDir/prometheus"

COPY "res/dynatracesourcesnmp" "$DsInstallDir/snmp"
COPY "res/ds.json_snmp" "$DsInstallDir/snmp/ds.json"
COPY "res/dynatracesourceprometheus" "$DsInstallDir/prometheus"
COPY "res/ds.json_prometheus" "$DsInstallDir/prometheus/ds.json"
COPY "./res/entrypoint.sh" "/entrypoint.sh"
RUN chmod a+x "/entrypoint.sh"

USER 1001

ENTRYPOINT [ "/bin/sh", "/entrypoint.sh" ]
