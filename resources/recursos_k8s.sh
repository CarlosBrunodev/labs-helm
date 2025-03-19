#!/bin/bash

OUTPUT_FILE="namespace_resources.csv"

echo "Namespace,Request CPU (m),Request Memory (Mi),Limit CPU (m),Limit Memory (Mi)" > "$OUTPUT_FILE"

NAMESPACES=$(kubectl get ns --no-headers -o custom-columns=":metadata.name")

for NS in $NAMESPACES; do
    echo "Processando namespace: $NS"
  
    PODS_JSON=$(kubectl get pod -n "$NS" -o json)

    SUM_REQUEST_CPU=$(echo "$PODS_JSON" | jq '[.items[].spec.containers[].resources.requests.cpu // "0"] 
        | map(select(. != null)) 
        | map(if endswith("m") then .[:-1] | tonumber else tonumber * 1000 end) 
        | add // 0')

    SUM_REQUEST_MEM=$(echo "$PODS_JSON" | jq '[.items[].spec.containers[].resources.requests.memory // "0Mi"] 
        | map(select(. != null)) 
        | map(
            if endswith("Ki") then .[:-2] | tonumber / 1024
            elif endswith("Mi") then .[:-2] | tonumber
            elif endswith("Gi") then .[:-2] | tonumber * 1024
            elif endswith("Ti") then .[:-2] | tonumber * 1024 * 1024
            else tonumber / 1024 end) 
        | add // 0')

    SUM_LIMIT_CPU=$(echo "$PODS_JSON" | jq '[.items[].spec.containers[].resources.limits.cpu // "0"] 
        | map(select(. != null)) 
        | map(if endswith("m") then .[:-1] | tonumber else tonumber * 1000 end) 
        | add // 0')

    SUM_LIMIT_MEM=$(echo "$PODS_JSON" | jq '[.items[].spec.containers[].resources.limits.memory // "0Mi"] 
        | map(select(. != null)) 
        | map(
            if endswith("Ki") then .[:-2] | tonumber / 1024
            elif endswith("Mi") then .[:-2] | tonumber
            elif endswith("Gi") then .[:-2] | tonumber * 1024
            elif endswith("Ti") then .[:-2] | tonumber * 1024 * 1024
            else tonumber / 1024 end) 
        | add // 0')

    echo "$NS,$SUM_REQUEST_CPU,$SUM_REQUEST_MEM,$SUM_LIMIT_CPU,$SUM_LIMIT_MEM" >> "$OUTPUT_FILE"
done

echo "Arquivo $OUTPUT_FILE gerado com sucesso!"