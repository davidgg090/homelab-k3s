#!/bin/bash
# fix-deployments.sh - Script para corregir todos los deployments con problemas

echo "🔧 Corrigiendo deployments con problemas de SecurityContext..."

# Función para parchear deployments de LinuxServer
patch_linuxserver_deployment() {
    local app=$1
    local image=$2
    echo "📦 Actualizando $app..."
    
    kubectl patch deployment $app -n homelab --type='json' -p='[
        {"op": "replace", "path": "/spec/template/spec/containers/0/image", "value": "'$image'"},
        {"op": "replace", "path": "/spec/template/spec/containers/0/securityContext/runAsNonRoot", "value": false},
        {"op": "replace", "path": "/spec/template/spec/containers/0/securityContext/runAsUser", "value": 0},
        {"op": "add", "path": "/spec/template/spec/containers/0/securityContext/capabilities/add", "value": ["CHOWN", "DAC_OVERRIDE", "SETGID", "SETUID", "KILL", "FOWNER"]}
    ]'
}

# Eliminar los pods antiguos que están en CrashLoopBackOff
echo "🗑️  Eliminando pods en mal estado..."
kubectl delete pod -n homelab plex-64d5bccfc4-mbf86 --force --grace-period=0 2>/dev/null
kubectl delete pod -n homelab jellyfin-56cdbcf8cc-5x7vv --force --grace-period=0 2>/dev/null
kubectl delete pod -n homelab qbittorrent-6465f65f7f-xx5xh --force --grace-period=0 2>/dev/null
kubectl delete pod -n homelab sonarr-5894c9fb7-w9vhn --force --grace-period=0 2>/dev/null
kubectl delete pod -n homelab radarr-6db996d5c6-8fcvs --force --grace-period=0 2>/dev/null
kubectl delete pod -n homelab pihole-74b9d98864-phkcz --force --grace-period=0 2>/dev/null

# Parchear LinuxServer deployments
patch_linuxserver_deployment "plex" "lscr.io/linuxserver/plex:latest"
patch_linuxserver_deployment "jellyfin" "lscr.io/linuxserver/jellyfin:latest"
patch_linuxserver_deployment "qbittorrent" "lscr.io/linuxserver/qbittorrent:latest"
patch_linuxserver_deployment "sonarr" "lscr.io/linuxserver/sonarr:latest"
patch_linuxserver_deployment "radarr" "lscr.io/linuxserver/radarr:latest"
patch_linuxserver_deployment "bazarr" "lscr.io/linuxserver/bazarr:latest"
patch_linuxserver_deployment "jackett" "lscr.io/linuxserver/jackett:latest"
patch_linuxserver_deployment "overseerr" "lscr.io/linuxserver/overseerr:latest"

# Corregir pgAdmin
echo "📦 Actualizando pgAdmin..."
kubectl patch deployment pgadmin -n homelab --type='json' -p='[
    {"op": "replace", "path": "/spec/template/spec/containers/0/image", "value": "dpage/pgadmin4:8.14"},
    {"op": "remove", "path": "/spec/template/spec/containers/0/securityContext/allowPrivilegeEscalation"},
    {"op": "remove", "path": "/spec/template/spec/containers/0/securityContext/capabilities"}
]'

# Corregir Mongo Express
echo "📦 Actualizando Mongo Express..."
kubectl patch deployment mongo-express -n homelab --type='json' -p='[
    {"op": "replace", "path": "/spec/template/spec/containers/0/image", "value": "mongo-express:0.54.0"}
]'

# MongoDB - volver a latest
echo "📦 Actualizando MongoDB..."
kubectl patch statefulset mongodb -n homelab --type='json' -p='[
    {"op": "replace", "path": "/spec/template/spec/containers/0/image", "value": "mongo:latest"}
]'

echo "✅ Patches aplicados. Esperando a que los pods se reinicien..."
sleep 5

# Ver estado
echo "📊 Estado actual de los pods:"
kubectl get pods -n homelab | grep -E "(plex|jellyfin|sonarr|radarr|qbittorrent|bazarr|jackett|overseerr|pgadmin|mongo-express|mongodb)"