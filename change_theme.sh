#!/bin/bash

# Récupère les heures de lever et de coucher du soleil pour votre emplacement
location="latitude=46.9497&longitude=4.3091"
sun_info=$(curl -s "https://api.sunrise-sunset.org/json?$location" | jq -r '.results')

# Extraction des heures de lever et de coucher du soleil
sunrise=$(echo "$sun_info" | jq -r '.sunrise')
sunset=$(echo "$sun_info" | jq -r '.sunset')

# Vérifie si les appels curl ont réussi
if [ -z "$sunrise" ] || [ -z "$sunset" ]; then
    echo "Erreur lors de la récupération des heures de lever et de coucher du soleil."
    exit 1
fi

# Convertit les heures du lever et du coucher du soleil en heures et minutes
sunrise_hour=$(date --date="$sunrise" +%H)
sunrise_minute=$(date --date="$sunrise" +%M)
sunset_hour=$(date --date="$sunset" +%H)
sunset_minute=$(date --date="$sunset" +%M)

# Récupère l'heure actuelle au format 24 heures, et les minutes
current_hour=$(date +%H)
current_minute=$(date +%M)

# Heure d'émulation spécifiée par l'utilisateur (par défaut, utilise l'heure actuelle)
emulated_hour=$current_hour

# Vérifie si l'option -h est spécifiée pour émuler une heure
while getopts ":h:" opt; do
    case $opt in
        h)
            emulated_hour=$OPTARG
            ;;
        \?)
            echo "Option invalide: -$OPTARG" >&2
            exit 1
            ;;
    esac
done

echo "Heure actuelle (émulée) : $emulated_hour:$current_minute"
echo "Heure de lever du soleil : $sunrise_hour:$sunrise_minute"
echo "Heure de coucher du soleil : $sunset_hour:$sunset_minute"

# Spécifiez les noms des thèmes
daylight_theme="org.kde.breeze.desktop"
night_theme="org.kde.breezedark.desktop"
sunset_theme="org.kde.breezesunset.desktop"

# Emplacement du fichier pour stocker et afficher le dernier thème appliqué
theme_file="$HOME/.last_theme"

# Définit la variable avec le contenu du fichier
current_theme=$(cat "$theme_file")

# Affiche la valeur de la variable
echo "Thème actuel : $current_theme"

# Fonction pour déterminer le thème en fonction de l'heure
get_theme_based_on_hour() {
    if [ "$emulated_hour" -ge "$sunset_hour" ] || [ "$emulated_hour" -lt "$sunrise_hour" ]; then
        echo "org.kde.breezedark.desktop"
    else
        echo "org.kde.breeze.desktop"
    fi
}


# Appelle la fonction pour obtenir le thème
theme_to_apply=$(get_theme_based_on_hour)

# Affiche le thème à appliquer
echo "Thème à appliquer : $theme_to_apply"

# Vérifie si le thème actuel est différent du thème à appliquer
while [ "$current_theme" != "$theme_to_apply" ]; do
    # Applique le thème
    echo "Application du thème : $theme_to_apply"
    lookandfeeltool -a "$theme_to_apply"

    # Enregistre le thème appliqué dans le fichier
    echo "$theme_to_apply" > "$theme_file"

    # Attend 1 seconde avant de vérifier à nouveau
    sleep 1

    # Met à jour la variable avec le contenu du fichier
    current_theme=$(cat "$theme_file")
done



# Convertit les heures du lever et du coucher du soleil en heures
sunrise_hour=$(date --date="$sunrise" +%H)
sunset_hour=$(date --date="$sunset" +%H)

# Sauvegarder la crontab actuelle de l'utilisateur neocraft
sudo crontab -l -u neocraft > crontab_backup

# Filtrer les lignes qui exécutent le script actuel ($0)
grep -v "$0" crontab_backup | sudo crontab -u neocraft -

# Programmer l'exécution du script aux heures de lever et de coucher du soleil
(crontab -l ; echo "$sunrise_minute $sunrise_hour * * * $0") | crontab -
(crontab -l ; echo "$sunset_minute $sunset_hour * * * $0") | crontab -

# Afficher un message indiquant que le script est maintenant programmé
echo "Le script est maintenant programmé pour s'exécuter à $sunrise_hour:$sunrise_minute (lever du soleil) et à $sunset_hour:$sunset_minute (coucher du soleil)."