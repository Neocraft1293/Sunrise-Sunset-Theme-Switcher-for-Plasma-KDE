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
#extraire la ville
city=$(echo "$location_info" | jq -r '.city')
postal=$(echo "$location_info" | jq -r '.postal')
region=$(echo "$location_info" | jq -r '.region')
country=$(echo "$location_info" | jq -r '.country')
timezone=$(echo "$location_info" | jq -r '.timezone')
echo "vous etes a $city $postal $region $country et votre fuseau horaire est $timezone"
org=$(echo "$location_info" | jq -r '.org')
echo "votre fournisseur d'acces est $org"

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

#envoyer un message discord avec les heures de lever et de coucher du soleil

# Convertir les heures de l'API Sunrise-Sunset au format 24 heures
sunrise_24=$(date -d "$sunrise" +"%H:%M")
sunset_24=$(date -d "$sunset" +"%H:%M")
#recuperer l'heure actuelle par rapport au fuseau horaire $timezone
current_time_24=$(TZ=$timezone date +"%H:%M")



#envoyer un message discord avec l'heure actuelle
echo "heure actuelle : $current_time_24"
# Comparer les heures au format 24 heures
if [[ "$current_time_24" > "$sunrise_24" && "$current_time_24" < "$sunset_24" ]]; then
    sun_status="le soleil est actuellement levé"
    next_event_time="$sunset_24"
    next_event="coucher"
    plasma-apply-colorscheme BreezeClassic
else
    sun_status="le soleil est actuellement couché"
    next_event_time="$sunrise_24"
    next_event="lever"
    plasma-apply-colorscheme BreezeDark
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
echo "le script va attendre $random_number secondes avant de programmer la prochaine execution"
sleep $random_number


#c'est pour eviter que le script ne s'execute pas en meme temps au cas ou il y a plusieur fois le script qui s'execute en meme temps
#et surtout pour eviter que le script ne programme plusieur fois la meme tache

# Vérifier si une tâche avec le nom "change_theme" existe déjà
existing_task=$(atq | grep -F 'change_theme' | cut -f1)



#recuperer le resultat de la commande atq
atq=$(echo $(atq))
echo "atq : $atq"
#si le resultat de la commande atq est vide alors on programme le script
if [ -z "$atq" ]; then #si le resultat de la commande atq est vide alors on programme le script
    echo "il n'y a pas de tache programmée"
    #programmer le script
    at -t "$next_event_datetime" -f "$0"
    #enregistre dans le fichier de log la date et l'heure de la prochaine execution
    echo $next_event_datetime > $mark_file
    else
    echo "il y a une tache programmée"
fi


#reattendre un temp random entre 1 et une minute
random_number=$((1 + RANDOM % 60))
echo "le script va attendre $random_number secondes avant de programmer la prochaine execution"
sleep $random_numbers







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
