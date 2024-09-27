#!/bin/bash

# Variables
OUTPUT_FILE="/var/log/open_ports_security_report.log"
EMAIL="admin@example.com" # CHANGE THIS
KNOWN_PORTS=(22 80 443 3306)  # Liste des ports connus
THRESHOLD_PORT=1024           # Seuil au-dessus duquel les ports non standard sont surveillés

# Début de la surveillance des ports ouverts
echo "### Scan des ports ouverts à $(date) ###" > "$OUTPUT_FILE"
netstat -tuln | grep LISTEN >> "$OUTPUT_FILE"

# Détection des services sur des ports non standard
echo -e "\n### Services sur des ports non standard ###" >> "$OUTPUT_FILE"
while read -r line; do
  PORT=$(echo "$line" | awk '{print $4}' | sed 's/.*://')
  if [[ ! " ${KNOWN_PORTS[@]} " =~ " $PORT " && $PORT -gt $THRESHOLD_PORT ]]; then
    echo "Service non standard sur le port $PORT détecté : $line" >> "$OUTPUT_FILE"
  fi
done < <(netstat -tuln | grep LISTEN)

# Vérification des ports connus sur lesquels un service ne devrait pas écouter
echo -e "\n### Vérification des ports critiques ###" >> "$OUTPUT_FILE"
for known_port in "${KNOWN_PORTS[@]}"; do
  if ! netstat -tuln | grep ":$known_port " > /dev/null; then
    echo "Aucun service détecté sur le port $known_port, possible faille de sécurité." >> "$OUTPUT_FILE"
  fi
done

# Envoi du rapport par email
mail -s "Rapport de sécurité des ports ouverts" "$EMAIL" < "$OUTPUT_FILE"