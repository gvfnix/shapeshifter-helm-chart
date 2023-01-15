#!/bin/bash
_indent=2
for attribute in $@; do
    attrName=${attribute/:*}
    attrType=${attribute/*:}
    if [[ $attrName = "--indent" ]]; then _indent=$attrType; continue; fi
    echo "{{- with \$$attrName := coalesce ($deploymentConf.pod).$attrName (\$.Values.general.deployments.pod).$attrName (\$.Values.general.pods).$attrName }}"
    if [[ $attrType = "yaml" ]]; then
        echo "$attrName:"
        echo "  {{- toYaml \$$attrName | nindent $_indent }}"
    else
        echo "$attrName: {{ \$$attrName }}"
    fi;
    echo "{{- end }}"
done