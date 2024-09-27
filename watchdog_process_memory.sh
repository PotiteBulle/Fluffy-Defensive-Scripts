#!/bin/bash

# Variables
OUTPUT_FILE="/var/log/suspect_processes.log"
KEYWORDS=("nc" "nmap" "hydra" "john" "aircrack-ng" "metasploit" "netcat") # TRIGGERS PATTERNS (CHANGE THIS)
MAX_MEMORY_USAGE=50000  # Limite de la mémoire en Ko (ex. 50 Mo = 50000)
EMAIL="admin@example.com" # CHANGE THIS

# Journalisation du début de la surveillance
echo "### Surveillance des processus suspects démarrée à $(date) ###" >> "$OUTPUT_FILE"

# Boucle pour vérifier les processus suspects
for keyword in "${KEYWORDS[@]}"; do
  ps aux --sort=-%mem | grep -v grep | grep "$keyword" >> "$OUTPUT_FILE"
done

# Vérification de la consommation mémoire des processus détectés
echo -e "\n### Processus suspects avec une consommation mémoire élevée ###" >> "$OUTPUT_FILE"
while read -r line; do
  PID=$(echo "$line" | awk '{print $2}')  # Extraction du PID du processus
  MEM_USAGE=$(pmap "$PID" | tail -n 1 | awk '/[0-9]K/{print $2}' | tr -d 'K')  # Récupération de l'utilisation mémoire
  if [[ "$MEM_USAGE" -gt "$MAX_MEMORY_USAGE" ]]; then
    echo "Processus $PID utilise plus de $MAX_MEMORY_USAGE Ko : $MEM_USAGE Ko" >> "$OUTPUT_FILE"
  fi
done < <(ps aux | grep -v grep | grep -E "$(IFS=\|; echo "${KEYWORDS[*]}")")

# Envoi du rapport par email si des processus suspects sont trouvés
if grep -q "$keyword" "$OUTPUT_FILE"; then
  mail -s "Alerte : Processus suspects détectés" "$EMAIL" < "$OUTPUT_FILE"
fi

# Fin de la surveillance
echo "### Fin de la surveillance à $(date) ###" >> "$OUTPUT_FILE"