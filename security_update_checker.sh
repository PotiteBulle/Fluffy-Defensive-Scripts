#!/bin/bash

# Variables
SEC_UPDATES=$(apt list --upgradable 2>/dev/null | grep -i security)
OUTPUT_FILE="/var/log/security_updates_report.log"
EMAIL="admin@example.com" # CHANGE THIS

# Mise à jour de la liste des paquets
echo "### Mise à jour des paquets à $(date) ###" >> "$OUTPUT_FILE"
sudo apt update >> "$OUTPUT_FILE" 2>&1

# Vérification des mises à jour de sécurité
if [[ -n "$SEC_UPDATES" ]]; then
  echo "### Correctifs de sécurité disponibles ###" >> "$OUTPUT_FILE"
  echo "$SEC_UPDATES" >> "$OUTPUT_FILE"

  # Installation des mises à jour de sécurité
  echo "### Installation des correctifs de sécurité à $(date) ###" >> "$OUTPUT_FILE"
  sudo apt upgrade -y >> "$OUTPUT_FILE" 2>&1
else
  echo "### Aucun correctif de sécurité trouvé à $(date) ###" >> "$OUTPUT_FILE"
fi

# Analyse des vulnérabilités connues via apt
echo -e "\n### Analyse des vulnérabilités connues ###" >> "$OUTPUT_FILE"
sudo apt-get install --dry-run unattended-upgrades >> "$OUTPUT_FILE" 2>&1
sudo apt-get install --dry-run debsecan >> "$OUTPUT_FILE" 2>&1
sudo debsecan >> "$OUTPUT_FILE" 2>&1

# Envoi du rapport par email
mail -s "Rapport des mises à jour de sécurité et vulnérabilités" "$EMAIL" < "$OUTPUT_FILE"

# Nettoyage des logs pour éviter l'accumulation excessive
if [[ $(wc -l < "$OUTPUT_FILE") -gt 1000 ]]; then
  > "$OUTPUT_FILE"
fi