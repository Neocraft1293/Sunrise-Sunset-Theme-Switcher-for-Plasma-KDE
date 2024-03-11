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

# Planifier l'exécution du script pour le prochain lever ou coucher de soleil
at -t "$next_event_datetime" <<EOF
"$0"
EOF
echo "le chemin du script est $0"
