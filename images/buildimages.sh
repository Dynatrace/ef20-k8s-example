#/bin/bash

cp /opt/dynatrace/remotepluginmodule/agent/datasources/snmp/ds.json eec/res/ds.json_snmp
cp /opt/dynatrace/remotepluginmodule/agent/datasources/prometheus/ds.json eec/res/ds.json_prometheus
cp /opt/dynatrace/remotepluginmodule/agent/lib64/extensionsmodule eec/res
cp /opt/dynatrace/remotepluginmodule/agent/lib64/extensionsmodule.hmac eec/res
ret=$(docker build eec -t eec_local:0.0.1)
echo $ret

cp /opt/dynatrace/remotepluginmodule/agent/datasources/snmp/ds.json datasources/res/ds.json_snmp
cp /opt/dynatrace/remotepluginmodule/agent/datasources/snmp/dynatracesourcesnmp datasources/res
cp /opt/dynatrace/remotepluginmodule/agent/datasources/prometheus/ds.json datasources/res/ds.json_prometheus
cp /opt/dynatrace/remotepluginmodule/agent/datasources/prometheus/dynatracesourceprometheus datasources/res

ret=$(docker build datasources -t datasources_local:0.0.1)
echo $ret