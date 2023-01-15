#!/bin/bash
_indent=2
_src="\$containerConf"
for attribute in $@; do
    attrName=${attribute/:*}
    attrType=${attribute/*:}
    if [[ $attrName = "--indent" ]]; then _indent=$attrType; continue; fi
    if [[ $attrName = "--src" ]]; then _src="${attrType}"; continue; fi
    echo "{{- with $_src.$attrName }}"
    if [[ $attrType = "yaml" ]]; then
        echo "$attrName:"
        echo "{{- toYaml . | nindent $_indent }}"
    else
        echo "$attrName: {{ . }}"
    fi;
    echo "{{- end }}"
done