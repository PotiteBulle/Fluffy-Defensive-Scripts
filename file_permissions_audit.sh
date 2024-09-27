#!/bin/bash

# Fichiers sensibles à vérifier
FILES=("/etc/passwd" "/etc/shadow" "/etc/hosts" "/etc/ssh/sshd_config") # CHANGE THIS 
OUTPUT_FILE="/var/log/file_permissions_security.log"
EMAIL="admin@example.com" # CHANGE THIS

# Vérification des permissions et des propriétaires
echo "### Vérification des permissions et propriétaires des fichiers sensibles ###" > "$OUTPUT_FILE"
for file in "${FILES[@]}"; do
  if [[ -f "$file" ]]; then
    PERMISSIONS=$(stat -c "%a %n" "$file")
    OWNER=$(stat -c "%U:%G" "$file")
    echo "Fichier : $file" >> "$OUTPUT_FILE"
    echo "Permissions : $PERMISSIONS" >> "$OUTPUT_FILE"
    echo "Propriétaire : $OWNER" >> "$OUTPUT_FILE"

    # Alerte si les permissions sont trop permissives
    if [[ "$PERMISSIONS" -gt 644 ]]; then
      echo "Alerte : Permissions trop permissives pour $file !" >> "$OUTPUT_FILE"
    fi

    # Alerte si l'utilisateur ou le groupe est incorrect
    if [[ "$OWNER" != "root:root" ]]; then
      echo "Alerte : Mauvais propriétaire pour $file !" >> "$OUTPUT_FILE"
    fi
  else
    echo "Fichier introuvable : $file" >> "$OUTPUT_FILE"
  fi
done

# Envoi du rapport par email
mail -s "Rapport de sécurité des fichiers sensibles" "$EMAIL" < "$OUTPUT_FILE"