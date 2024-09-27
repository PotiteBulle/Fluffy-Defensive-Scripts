#!/bin/bash

# Variables
LOG_DIR="/var/log"  # Répertoire où sera stocké le fichier de log
OUTPUT_FILE="$LOG_DIR/security_updates_report.log"  # Chemin du fichier de log
EMAIL="admin@example.com"  # Adresse email où sera envoyé le rapport (à modifier)
MAX_LOG_SIZE=1000  # Limite de lignes pour le fichier de log avant le nettoyage

# Fonction pour ajouter des messages au fichier de log avec un timestamp
log_message() {
  echo "### $1 à $(date) ###" >> "$OUTPUT_FILE"  # Ajoute un message avec la date et l'heure au fichier de log
}

# Création du fichier log s'il n'existe pas encore
if [[ ! -f "$OUTPUT_FILE" ]]; then
  touch "$OUTPUT_FILE"  # Crée le fichier de log si nécessaire
fi

# Nettoyage du fichier de log s'il dépasse la taille maximale définie
if [[ $(wc -l < "$OUTPUT_FILE") -gt $MAX_LOG_SIZE ]]; then
  > "$OUTPUT_FILE"  # Vide le fichier de log si le nombre de lignes dépasse la limite
fi

# Mise à jour de la liste des paquets disponibles
log_message "Mise à jour des paquets"  # Log du début de la mise à jour des paquets
sudo apt update >> "$OUTPUT_FILE" 2>&1  # Exécute la commande 'apt update' et redirige la sortie vers le fichier de log

# Vérification des mises à jour de sécurité disponibles
SEC_UPDATES=$(apt list --upgradable 2>/dev/null | grep -i security)  # Cherche les mises à jour de sécurité parmi les paquets disponibles

if [[ -n "$SEC_UPDATES" ]]; then  # Si des mises à jour de sécurité sont trouvées
  log_message "Correctifs de sécurité disponibles"  # Log du début de l'installation des mises à jour de sécurité
  echo "$SEC_UPDATES" >> "$OUTPUT_FILE"  # Ajoute la liste des mises à jour de sécurité au fichier de log

  # Installation des mises à jour de sécurité
  log_message "Installation des correctifs de sécurité"  # Log de l'installation des correctifs de sécurité
  sudo apt upgrade -y >> "$OUTPUT_FILE" 2>&1  # Exécute la mise à jour avec confirmation automatique et enregistre la sortie dans le fichier de log
else
  log_message "Aucun correctif de sécurité trouvé"  # Log si aucune mise à jour de sécurité n'est disponible
fi

# Analyse des vulnérabilités connues avec 'debsecan' et 'unattended-upgrades'
log_message "Analyse des vulnérabilités connues"  # Log du début de l'analyse des vulnérabilités
{
  sudo apt-get install --dry-run unattended-upgrades  # Simule l'installation d'‘unattended-upgrades’ pour vérifier sa disponibilité
  sudo apt-get install --dry-run debsecan  # Simule l'installation de 'debsecan'
  sudo debsecan  # Exécute 'debsecan' pour lister les vulnérabilités connues sur le système
} >> "$OUTPUT_FILE" 2>&1  # Redirige toutes les sorties vers le fichier de log

# Envoi du rapport par email
mail -s "Rapport des mises à jour de sécurité et vulnérabilités" "$EMAIL" < "$OUTPUT_FILE"  # Envoie le fichier de log par email à l'adresse spécifiée