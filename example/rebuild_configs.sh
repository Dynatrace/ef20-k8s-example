#!/bin/bash

ret=$(kubectl delete secret extension-generic-cisco)
echo $ret

ret=$(kubectl delete secret extension-palo-alto)
echo $ret

ret=$(kubectl delete secret extension-rabbitmq)
echo $ret

ret=$(kubectl delete configmap runtime-configuration)
echo $ret

#r#et=$(kubectl delete configmap config)
echo $ret

ret=$(kubectl delete secret agsecrets)
echo $ret

ret=$(kubectl create secret generic extension-palo-alto --from-file=extensions/com.dynatrace.extension.palo-alto-generic)
echo $ret

ret=$(kubectl create secret generic extension-generic-cisco --from-file=extensions/com.dynatrace.extension.snmp-generic-cisco-device)
echo $ret

ret=$(kubectl create secret generic extension-rabbitmq --from-file=extensions/com.dynatrace.extension.prometheus-rabbitmq)
echo $ret

ret=$(kubectl create configmap runtime-configuration --from-file=runtimeConfiguration)
echo $ret

ret=$(kubectl create -f agsecrets.yaml)
echo $ret

ret=$(kubectl create -f config.yaml)
echo $re
