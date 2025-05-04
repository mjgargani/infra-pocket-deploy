#!/bin/bash

JSON_FILE="./../config/app.json"

# Verifica se jq está instalado
if ! command -v jq >/dev/null 2>&1; then
  echo "[ERRO] O utilitário 'jq' não está instalado. Instale-o com:"
  echo "  apt install -y jq"
  exit 1
fi

# Verifica se o arquivo JSON existe
if [ ! -f "$JSON_FILE" ]; then
  echo "[ERRO] Arquivo $JSON_FILE não encontrado."
  exit 2
fi

echo "[INFO] Exportando variáveis do $JSON_FILE para TF_VAR_..."

# Loop pelas chaves do JSON e exporta como TF_VAR_...
for key in $(jq -r 'keys[]' "$JSON_FILE"); do
  value=$(jq -r --arg k "$key" '.[$k]' "$JSON_FILE")
  export TF_VAR_$key="$value"
done

echo "[SUCESSO] Variáveis exportadas:"
env | grep TF_VAR_
