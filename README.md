# Sunrise Sunset Theme Switcher

Ce script Shell utilise deux API pour déterminer si le soleil est actuellement levé ou couché à une localisation donnée, puis ajuste automatiquement le thème de couleur du bureau KDE Plasma en conséquence. Il utilise l'API ipinfo.io pour obtenir des informations sur l'adresse IP publique et la localisation géographique approximative, ainsi que l'API sunrise-sunset.org pour obtenir des informations précises sur les heures de lever et de coucher du soleil.

## Les API Utilisées

### ipinfo.io

L'API ipinfo.io fournit des informations sur l'adresse IP publique du système, y compris la localisation géographique approximative.

### sunrise-sunset.org

L'API sunrise-sunset.org fournit des informations précises sur les heures de lever et de coucher du soleil pour une localisation donnée.

## Prérequis

- Linux
- Bureau KDE Plasma
- `jq` (command-line JSON processor) doit être installé (`sudo apt-get install jq` sur Ubuntu/Debian)
- `at` (planificateur de tâches) doit être installé et le service `atd` doit être en cours d'exécution. Vous pouvez l'installer avec `sudo apt-get install at` sur Ubuntu/Debian.

## Fonctionnalités

- Récupération automatique de l'adresse IP publique du système.
- Obtention des informations de localisation basées sur l'adresse IP publique à l'aide de l'API ipinfo.io.
- Détermination de l'heure du lever et du coucher du soleil pour cette localisation à l'aide de l'API sunrise-sunset.org.
- Réglage automatique du thème de couleur du bureau KDE Plasma en fonction de l'état du soleil.
- Planification de la prochaine exécution du script pour le prochain lever ou coucher du soleil.

## Utilisation

1. Clonez ce dépôt sur votre système local.
2. Assurez-vous que le script est exécutable : `chmod +x sunrise_sunset_theme_switcher.sh`.
3. Exécutez le script : `./sunrise_sunset_theme_switcher.sh`.

## Configuration

Aucune configuration requise. Le script récupère automatiquement l'adresse IP publique, obtient les informations de localisation, ajuste le thème de couleur et planifie la prochaine exécution.

## Licence

Ce projet est sous licence [CC BY-SA 4.0](LICENSE). Consultez le fichier [LICENSE](LICENSE) pour plus de détails.
