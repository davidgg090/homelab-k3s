#!/bin/bash
# manual-fix-commands.sh - Comandos manuales para corregir cada deployment

echo "🔧 Comandos manuales para corregir deployments"
echo "Ejecuta cada comando uno por uno si el script automático falla:"
echo ""

# Para cada aplicación LinuxServer, necesitamos quitar las restricciones de seguridad
echo "# 1. Plex"
echo 'kubectl edit deployment plex -n homelab'
echo "# Cambia:"
echo "#   - runAsNonRoot: true -> runAsNonRoot: false"
echo "#   - runAsUser: 1000 -> runAsUser: 0"
echo "#   - image: a la versión :latest"
echo ""

echo "# 2. Jellyfin"
echo 'kubectl edit deployment jellyfin -n homelab'
echo "# Mismos cambios que Plex"
echo ""

echo "# 3. Sonarr"
echo 'kubectl edit deployment sonarr -n homelab'
echo "# Mismos cambios que Plex"
echo ""

echo "# 4. Radarr"
echo 'kubectl edit deployment radarr -n homelab'
echo "# Mismos cambios que Plex"
echo ""

echo "# 5. qBittorrent"
echo 'kubectl edit deployment qbittorrent -n homelab'
echo "# Mismos cambios que Plex"
echo ""

echo "# 6. MongoDB - cambiar a latest"
echo 'kubectl edit statefulset mongodb -n homelab'
echo "# Cambia image: mongo:7.0 -> mongo:latest"
echo ""

echo "# 7. pgAdmin"
echo 'kubectl edit deployment pgadmin -n homelab'
echo "# Cambia image a: dpage/pgadmin4:8.14"
echo ""

echo "# 8. Mongo Express"  
echo 'kubectl edit deployment mongo-express -n homelab'
echo "# Cambia image a: mongo-express:0.54.0"
echo ""

echo "# Alternativa: Eliminar y recrear deployments problemáticos"
echo "# Esto preservará los PVCs con los datos:"
echo ""
echo "kubectl delete deployment plex jellyfin sonarr radarr qbittorrent pgadmin mongo-express -n homelab"
echo "kubectl delete statefulset mongodb -n homelab"
echo ""
echo "# Luego aplica los archivos originales con las correcciones"