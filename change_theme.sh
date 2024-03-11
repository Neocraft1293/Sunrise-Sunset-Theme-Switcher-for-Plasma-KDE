#!/bin/bash

# Récupérer l'adresse IP publique du système
public_ip=$(curl -s https://ipinfo.io/ip)

# Vérifier si l'adresse IP publique est obtenue avec succès
if [ -z "$public_ip" ]; then
    echo "Impossible de récupérer l'adresse IP publique."
    exit 1
fi

# Afficher l'adresse IP publique
echo "Adresse IP publique : $public_ip"

# Récupérer les informations de localisation basées sur l'adresse IP publique
location_info=$(curl -s https://ipinfo.io/$public_ip)

# Vérifier si les informations de localisation sont obtenues avec succès
if [ -z "$location_info" ]; then
    echo "Impossible de récupérer les informations de localisation pour l'adresse IP $public_ip."
    exit 1
fi

# Extraire les coordonnées de latitude et de longitude
latitude=$(echo "$location_info" | jq -r '.loc' | cut -d ',' -f1)
longitude=$(echo "$location_info" | jq -r '.loc' | cut -d ',' -f2)

# Vérifier si les coordonnées de latitude et de longitude sont obtenues avec succès
if [ -z "$latitude" ] || [ -z "$longitude" ]; then
    echo "Impossible d'extraire les coordonnées de latitude et de longitude."
    exit 1
fi

# Formater les coordonnées dans la chaîne demandée
formatted_location="lat=$latitude&lng=$longitude"

# Appeler l'API Sunrise-Sunset avec les coordonnées de localisation
api_url="https://api.sunrise-sunset.org/json?$formatted_location"
sunrise_sunset_info=$(curl -s "$api_url")

# Extraire l'heure du lever et du coucher du soleil de la réponse de l'API
sunrise=$(echo "$sunrise_sunset_info" | jq -r '.results.sunrise')
sunset=$(echo "$sunrise_sunset_info" | jq -r '.results.sunset')

# Déterminer si le soleil est actuellement levé ou couché
current_time=$(date +%H:%M)
if [[ "$current_time" > "$sunrise" && "$current_time" < "$sunset" ]]; then
    sun_status="le soleil est actuellement levé"
    next_event_time="$sunset"
    next_event="coucher"
else
    sun_status="le soleil est actuellement couché"
    next_event_time="$sunrise"
    next_event="lever"
fi

# Calculer la date et l'heure du prochain lever ou coucher de soleil
next_event_datetime=$(date -d "$next_event_time" +"%Y%m%d%H%M")

# Afficher les informations sur le lever et le coucher du soleil ainsi que le statut du soleil
echo "Informations sur le lever et le coucher du soleil pour les coordonnées $formatted_location :"
echo "Heure de lever du soleil : $sunrise"
echo "Heure de coucher du soleil : $sunset"
echo "Actuellement, $sun_status."

# Afficher le prochain événement et planifier l'exécution du script
echo "Prochain événement : $next_event du soleil à $next_event_time."
echo "Planification de l'exécution du script pour le prochain $next_event du soleil..."


#attendre un temp random entre 1 et une minute

#gener un nombbre random entre 1 et 60
random_number=$((1 + RANDOM % 60))
random_number=0
echo "le script va attendre $random_number secondes avant de programmer la prochaine execution"
sleep $random_number


#c'est pour eviter que le script ne s'execute pas en meme temps au cas ou il y a plusieur fois le script qui s'execute en meme temps
#et surtout pour eviter que le script ne programme plusieur fois la meme tache

# Vérifier si une tâche avec le nom "change_theme" existe déjà
existing_task=$(atq | grep -F 'change_theme' | cut -f1)

# Déterminer le répertoire du script
script_dir=$(dirname "$0")
mark_file="$script_dir/fichier_de_log" # Créer un fichier de log pour marquer la prochaine exécution du script
# met le contenue du fichier dans une variable
mark_file_content=$(cat "$mark_file")
#echo $mark_file_content
echo "mark_file_content : $mark_file_content"

#if mark_file_content = next_event_datetime
if [ "$mark_file_content" = "$next_event_datetime" ]; then
    echo "La prochaine exécution du script est déjà planifiée pour le prochain event."
    else
    echo "La prochaine exécution du script n'est pas encore planifiée."
    echo $next_event_datetime > $mark_file
    echo "La prochaine exécution du script est planifiée pour le prochain event."
    at -t "$next_event_datetime" -f "$0"
fi


echo "next_event_datetime : $next_event_datetime"

#at -t "$next_event_datetime" -f "$0"
