FROM registry.access.redhat.com/ubi8/ubi-minimal:8.6

ARG EecArtifactsDir

ENV EecTokenPath="/var/lib/dynatrace/gateway/config/eec.token"
ENV ExtensionsConfPath="/opt/dynatrace/remotepluginmodule/agent/conf/extensions.conf"

ENV DsInstallDir="/opt/dynatrace/remotepluginmodule/agent/datasources"
ENV ExtensionsModuleExecPath="/opt/dynatrace/remotepluginmodule/agent/lib64/extensionsmodule"
ENV DumpProcModuleExecPath="/oneagentdumpproc"

ENV DsAuthTokenPath="/var/lib/dynatrace/remotepluginmodule/agent/runtime/datasources/dsauthtoken"
ENV SharedDsAuthTokenPath="/mnt/dsexecargs/dsauthtoken"

ENV TenantId=""
ENV ServerUrl=""
ENV EecIngestPort=14599
ENV DsProcessArgsDir="/mnt/dsexecargs"

RUN mkdir -p "$(dirname "$ExtensionsModuleExecPath")" \
    && mkdir -p "$(dirname "$ExtensionsConfPath")" \
    && mkdir -p "/var/lib/dynatrace/remotepluginmodule/log" \
    && mkdir -p "/opt/dynatrace/remotepluginmodule/agent/logs" \
    && mkdir -p "/opt/dynatrace/remotepluginmodule/agent/datasources\snmp" \
    && mkdir -p "/var/lib/dynatrace/remotepluginmodule/agent/conf" \
    && mkdir -p "/var/lib/dynatrace/remotepluginmodule/agent/runtime/extensions/cache/statsd/1.0.0"

COPY "./res/extensionsmodule" "$ExtensionsModuleExecPath"
COPY "./res/extensionsmodule.hmac" "$ExtensionsModuleExecPath.hmac"

COPY "./res/ds.json" "/opt/dynatrace/remotepluginmodule/agent/datasources/snmp/ds.json"

COPY "./res/extensions.conf" "$ExtensionsConfPath"
COPY "./res/entrypoint.sh" "/entrypoint.sh"

RUN chmod a+x "/entrypoint.sh" \
    && chmod a+x "$ExtensionsModuleExecPath" \
    && chmod a+w "$ExtensionsConfPath" \
    && chmod -R a+w "/var/lib/dynatrace/remotepluginmodule"

USER 1001

ENTRYPOINT [ "/bin/bash", "/entrypoint.sh" ]