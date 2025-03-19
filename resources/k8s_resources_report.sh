#!/bin/bash

OUTPUT_FILE="k8s_resources_report.csv"

# Cabeçalho do arquivo CSV
echo "Namespace,Deployment,Request CPU (m),Request Memory (Mi),Limit CPU (m),Limit Memory (Mi)" > "$OUTPUT_FILE"

# Lista todos os namespaces
NAMESPACES=$(kubectl get ns --no-headers -o custom-columns=":metadata.name")

for NS in $NAMESPACES; do
    echo "🔍 Processando namespace: $NS"

    # Lista todos os deployments no namespace
    DEPLOYMENTS=$(kubectl get deployment -n "$NS" --no-headers -o custom-columns=":metadata.name")

    for DEP in $DEPLOYMENTS; do
        echo "   📦 Processando deployment: $DEP"

        # Obtém JSON do deployment
        DEP_JSON=$(kubectl get deployment "$DEP" -n "$NS" -o json)

        # Calcula os requests e limits de CPU e Memória
        REQ_CPU=$(echo "$DEP_JSON" | jq '[.spec.template.spec.containers[].resources.requests.cpu // "0"]
            | map(select(. != null)) 
            | map(if endswith("m") then .[:-1] | tonumber else tonumber * 1000 end) 
            | add // 0')

        REQ_MEM=$(echo "$DEP_JSON" | jq '[.spec.template.spec.containers[].resources.requests.memory // "0Mi"]
            | map(select(. != null)) 
            | map(
                if endswith("Ki") then .[:-2] | tonumber / 1024
                elif endswith("Mi") then .[:-2] | tonumber
                elif endswith("Gi") then .[:-2] | tonumber * 1024
                elif endswith("Ti") then .[:-2] | tonumber * 1024 * 1024
                else tonumber / 1024 end) 
            | add // 0')

        LIMIT_CPU=$(echo "$DEP_JSON" | jq '[.spec.template.spec.containers[].resources.limits.cpu // "0"]
            | map(select(. != null)) 
            | map(if endswith("m") then .[:-1] | tonumber else tonumber * 1000 end) 
            | add // 0')

        LIMIT_MEM=$(echo "$DEP_JSON" | jq '[.spec.template.spec.containers[].resources.limits.memory // "0Mi"]
            | map(select(. != null)) 
            | map(
                if endswith("Ki") then .[:-2] | tonumber / 1024
                elif endswith("Mi") then .[:-2] | tonumber
                elif endswith("Gi") then .[:-2] | tonumber * 1024
                elif endswith("Ti") then .[:-2] | tonumber * 1024 * 1024
                else tonumber / 1024 end) 
            | add // 0')

        # Escreve no arquivo CSV
        echo "$NS,$DEP,$REQ_CPU,$REQ_MEM,$LIMIT_CPU,$LIMIT_MEM" >> "$OUTPUT_FILE"
    done
done

echo "✅ Arquivo $OUTPUT_FILE gerado com sucesso!"