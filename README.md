# 🏠 Homelab K3s - Stack de Medios Automatizado

<div align="center">

[![Kubernetes](https://img.shields.io/badge/kubernetes-v1.28-blue?style=for-the-badge&logo=kubernetes)](https://kubernetes.io/)
[![K3s](https://img.shields.io/badge/k3s-lightweight-orange?style=for-the-badge&logo=k3s)](https://k3s.io/)
[![License](https://img.shields.io/badge/license-MIT-green?style=for-the-badge)](LICENSE)

Un homelab robusto y automatizado para gestión de medios, construido con Kubernetes y siguiendo las mejores prácticas de seguridad y DevOps.

</div>

## 📋 Tabla de Contenidos

- [Vista General](#-vista-general)
- [Stack de Aplicaciones](#-stack-de-aplicaciones)
- [Arquitectura](#-arquitectura)
- [Características](#-características)
- [Requisitos](#-requisitos)
- [Instalación](#-instalación)
- [Configuración](#-configuración)
- [Uso](#-uso)
- [Monitoreo](#-monitoreo)
- [Seguridad](#-seguridad)
- [Mantenimiento](#-mantenimiento)
- [Troubleshooting](#-troubleshooting)

## 🎯 Vista General

Este proyecto implementa un **homelab completo** basado en K3s (Kubernetes ligero) que automatiza la descarga, organización y streaming de contenido multimedia. Está diseñado para ejecutarse en hardware modesto (Mini PC) mientras mantiene características empresariales como alta disponibilidad, monitoreo y seguridad.

### ¿Por qué este proyecto?

- **Automatización completa**: Desde la solicitud hasta el streaming
- **Gestión declarativa**: Todo como código (GitOps ready)
- **Seguridad first**: SecurityContext, Network Policies, gestión de secretos
- **Monitoreo integrado**: Prometheus + Grafana preconfigurados
- **Fácil mantenimiento**: Updates sin downtime, backups automatizables

## 🚀 Stack de Aplicaciones

### 🎬 Gestión de Medios
- **[Plex](https://www.plex.tv/)** / **[Jellyfin](https://jellyfin.org/)**: Servidores de streaming multimedia
- **[Sonarr](https://sonarr.tv/)**: Automatización de series de TV
- **[Radarr](https://radarr.video/)**: Automatización de películas
- **[Bazarr](https://www.bazarr.media/)**: Gestión automática de subtítulos
- **[Overseerr](https://overseerr.dev/)**: Portal de solicitudes de contenido

### 📥 Descargas
- **[qBittorrent](https://www.qbittorrent.org/)**: Cliente BitTorrent con WebUI
- **[Jackett](https://github.com/Jackett/Jackett)**: Proxy de indexadores de torrents

### 💾 Bases de Datos
- **[PostgreSQL](https://www.postgresql.org/)**: Base de datos relacional
- **[MongoDB](https://www.mongodb.com/)**: Base de datos NoSQL
- **[pgAdmin](https://www.pgadmin.org/)**: Administración web para PostgreSQL
- **[Mongo Express](https://github.com/mongo-express/mongo-express)**: Administración web para MongoDB

### 🛠️ Utilidades
- **[Homepage](https://gethomepage.dev/)**: Dashboard personalizable
- **[Pi-hole](https://pi-hole.net/)**: Bloqueador de anuncios a nivel DNS
- **Docker Registry**: Registro privado de imágenes

### 📊 Monitoreo
- **[Prometheus](https://prometheus.io/)**: Recolección de métricas
- **[Grafana](https://grafana.com/)**: Visualización y dashboards
- **Node Exporter**: Métricas del sistema
- **kube-state-metrics**: Métricas de Kubernetes

## 🏗️ Arquitectura

```
┌─────────────────────────────────────────────────────────────┐
│                        Internet                              │
└────────────────────────┬────────────────────────────────────┘
                         │
┌────────────────────────┴────────────────────────────────────┐
│                    Router/Firewall                           │
└────────────────────────┬────────────────────────────────────┘
                         │
┌────────────────────────┴────────────────────────────────────┐
│                 Mini PC (Ubuntu Server)                      │
│  ┌────────────────────────────────────────────────────────┐ │
│  │                      K3s Cluster                        │ │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐   │ │
│  │  │   Traefik   │  │ Media Stack │  │  Databases  │   │ │
│  │  │  (Ingress)  │  │ Plex/Sonarr │  │ PostgreSQL  │   │ │
│  │  └─────────────┘  └─────────────┘  └─────────────┘   │ │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐   │ │
│  │  │ Monitoring  │  │  Downloads  │  │  Utilities  │   │ │
│  │  │ Prometheus  │  │ qBittorrent │  │  Homepage   │   │ │
│  │  └─────────────┘  └─────────────┘  └─────────────┘   │ │
│  └────────────────────────────────────────────────────────┘ │
│                             │                                │
│  ┌──────────────────────────┴──────────────────────────┐   │
│  │              Storage Layer                           │   │
│  │  ┌─────────────┐        ┌────────────────────┐     │   │
│  │  │ SSD Internal│        │ USB External Drive │     │   │
│  │  │ /configs    │        │ /media (1TB)       │     │   │
│  │  └─────────────┘        └────────────────────┘     │   │
│  └──────────────────────────────────────────────────────┘   │
└──────────────────────────────────────────────────────────────┘
```

### 🔧 Componentes Clave

- **K3s**: Distribución ligera de Kubernetes
- **Traefik**: Ingress controller (incluido en K3s)
- **Local Path Provisioner**: Almacenamiento dinámico
- **CoreDNS**: Resolución DNS interna
- **Containerd**: Runtime de contenedores

## ✨ Características

### 🔒 Seguridad
- ✅ **SecurityContext** en todos los contenedores
- ✅ **Network Policies** con enfoque zero-trust
- ✅ **RBAC** configurado
- ✅ Gestión segura de secretos
- ✅ Contenedores ejecutándose como non-root
- ✅ Capacidades mínimas (drop ALL)

### 📈 Alta Disponibilidad
- ✅ **PodDisruptionBudgets** para servicios críticos
- ✅ **Health checks** (liveness, readiness, startup probes)
- ✅ Estrategias de deployment sin downtime
- ✅ Gestión de recursos (requests/limits)

### 🔍 Observabilidad
- ✅ Monitoreo completo con Prometheus
- ✅ Dashboards preconstruidos en Grafana
- ✅ Alertas configurables
- ✅ Logs centralizados
- ✅ Métricas de aplicación y sistema

### 🚀 DevOps
- ✅ GitOps ready
- ✅ CI/CD con GitHub Actions
- ✅ Versionado de imágenes
- ✅ Rollback automático
- ✅ Configuración declarativa

## 📋 Requisitos

### Hardware Mínimo
- **CPU**: 4 cores (Intel i3/i5 o equivalente)
- **RAM**: 8GB (16GB recomendado)
- **Almacenamiento**: 
  - SSD 128GB para sistema y configuraciones
  - HDD/SSD 1TB+ para contenido multimedia
- **Red**: Ethernet Gigabit

### Software
- **OS**: Ubuntu Server 22.04 LTS
- **K3s**: v1.28+
- **kubectl**: v1.28+
- **Helm**: v3.12+ (para Prometheus stack)
- **Git**: Para gestión de código

## 🛠️ Instalación

### 1. Preparación del Sistema

```bash
# Actualizar sistema
sudo apt update && sudo apt upgrade -y

# Instalar dependencias
sudo apt install -y curl wget git htop iotop

# Configurar IP estática (editar netplan)
sudo nano /etc/netplan/00-installer-config.yaml
```

### 2. Configurar Almacenamiento

```bash
# Crear directorios
sudo mkdir -p /mnt/lab/media/{movies,tv,downloads}
sudo mkdir -p /mnt/lab/config/{databases,apps}

# Montar disco USB (encontrar UUID con: sudo blkid)
echo "UUID=tu-uuid /mnt/lab/media ext4 defaults,nofail 0 2" | sudo tee -a /etc/fstab

# Establecer permisos
sudo chown -R 1000:1000 /mnt/lab
sudo chmod -R 755 /mnt/lab
```

### 3. Instalar K3s

```bash
# Instalar K3s sin ServiceLB (usaremos NodePort)
curl -sfL https://get.k3s.io | sh -

# Configurar kubectl para usuario no-root
mkdir -p ~/.kube
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
sudo chown $USER:$USER ~/.kube/config
chmod 600 ~/.kube/config

# Verificar instalación
kubectl get nodes
```

### 4. Clonar y Configurar el Proyecto

```bash
# Clonar repositorio
git clone https://github.com/tu-usuario/homelab-k3s.git
cd homelab-k3s

# Copiar y editar secretos
cp kubernetes/00-base/secrets-improved.template.yaml kubernetes/00-base/secrets.yaml
# Editar con tus valores reales
nano kubernetes/00-base/secrets.yaml
```

### 5. Desplegar Stack

```bash
# Aplicar configuración base
kubectl apply -f kubernetes/00-base/

# Aplicar almacenamiento
kubectl apply -f kubernetes/01-storage/

# Aplicar aplicaciones
kubectl apply -f kubernetes/02-apps/

# Aplicar PodDisruptionBudgets
kubectl apply -f kubernetes/02-apps/pdbs/

# Aplicar políticas de red (con cuidado)
kubectl apply -f kubernetes/04-network-policies/01-allow-dns.yaml
kubectl apply -f kubernetes/04-network-policies/02-allow-ingress-traffic.yaml
kubectl apply -f kubernetes/04-network-policies/03-app-to-app-communication.yaml
# Verificar conectividad antes de aplicar:
kubectl apply -f kubernetes/04-network-policies/00-default-deny-all.yaml
```

### 6. Instalar Stack de Monitoreo

```bash
# Agregar repositorio Helm
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Instalar kube-prometheus-stack
kubectl create namespace monitoring
helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  -f kubernetes/03-monitoring/kube-prometheus-stack-values.yaml
```

## ⚙️ Configuración

### DNS Local

Agrega estas entradas a tu servidor DNS o archivo hosts:

```
192.168.1.X plex.homelab.local
192.168.1.X jellyfin.homelab.local
192.168.1.X sonarr.homelab.local
192.168.1.X radarr.homelab.local
192.168.1.X overseerr.homelab.local
192.168.1.X homepage.homelab.local
192.168.1.X grafana.homelab.local
192.168.1.X pgadmin.homelab.local
192.168.1.X mongo-express.homelab.local
```

### Configuración de Aplicaciones

#### Sonarr/Radarr
1. Accede a `http://sonarr.homelab.local`
2. Configura indexadores (Jackett)
3. Configura cliente de descarga (qBittorrent)
4. Añade carpetas de medios

#### qBittorrent
1. Accede a `http://qbittorrent.homelab.local:30080`
2. Usuario: `admin`
3. Contraseña: La configurada en secrets

#### Plex
1. Accede a `http://plex.homelab.local`
2. Reclama el servidor con tu cuenta
3. Añade bibliotecas apuntando a `/data/movies` y `/data/tvshows`

## 📊 Uso

### Flujo de Trabajo

1. **Solicitud**: Usuario solicita contenido en Overseerr
2. **Búsqueda**: Sonarr/Radarr buscan en indexadores vía Jackett
3. **Descarga**: qBittorrent descarga el contenido
4. **Organización**: Sonarr/Radarr mueven y renombran archivos
5. **Subtítulos**: Bazarr descarga subtítulos automáticamente
6. **Streaming**: Plex/Jellyfin sirven el contenido

### Acceso a Servicios

| Servicio | URL | Puerto |
|----------|-----|--------|
| Plex | http://plex.homelab.local | 80 |
| Jellyfin | http://jellyfin.homelab.local | 80 |
| Sonarr | http://sonarr.homelab.local | 80 |
| Radarr | http://radarr.homelab.local | 80 |
| Overseerr | http://overseerr.homelab.local | 80 |
| qBittorrent | NodePort | 30080 |
| Homepage | http://homepage.homelab.local | 80 |
| Grafana | http://grafana.homelab.local | 80 |
| pgAdmin | http://pgadmin.homelab.local | 80 |
| Mongo Express | http://mongo-express.homelab.local | 80 |

## 📈 Monitoreo

### Dashboards Disponibles

- **Cluster Overview**: Estado general del cluster
- **Node Metrics**: CPU, memoria, disco, red
- **Pod Metrics**: Recursos por pod
- **Application Metrics**: Métricas específicas de aplicación

### Alertas Configuradas

- Alta utilización de CPU/memoria
- Pods en estado CrashLoopBackOff
- PVC casi llenos
- Nodos no disponibles

## 🔒 Seguridad

### Mejores Prácticas Implementadas

1. **Principio de Menor Privilegio**
   - Contenedores ejecutándose como non-root
   - Capacidades eliminadas (drop ALL)
   - ReadOnlyRootFilesystem donde es posible

2. **Network Policies**
   - Default deny all
   - Reglas explícitas para comunicación necesaria
   - Separación de namespaces

3. **Gestión de Secretos**
   - Secretos en Kubernetes Secrets
   - Valores en base64
   - Nunca commiteados en Git

4. **Actualizaciones**
   - Imágenes con versiones específicas
   - Actualizaciones controladas
   - Rollback automático si falla

## 🔧 Mantenimiento

### Actualizaciones de Aplicaciones

```bash
# Actualizar imagen en deployment
kubectl set image deployment/plex plex=lscr.io/linuxserver/plex:1.40.1 -n homelab

# O editar el archivo y aplicar
kubectl apply -f kubernetes/02-apps/plex/deployment.yaml
```

### Backup

```bash
# Backup de configuraciones
kubectl get all,pvc,pv,secrets,configmaps -n homelab -o yaml > backup-homelab.yaml

# Backup de datos (ejemplo con rsync)
rsync -avz /mnt/lab/config/ /backup/location/
```

### Monitoreo de Recursos

```bash
# Ver uso de recursos
kubectl top nodes
kubectl top pods -n homelab

# Ver logs
kubectl logs -n homelab deployment/sonarr

# Describir pod problemático
kubectl describe pod -n homelab <pod-name>
```

## 🐛 Troubleshooting

### Problemas Comunes

**Pod en CrashLoopBackOff**
```bash
# Ver logs del pod
kubectl logs -n homelab <pod-name> --previous

# Verificar eventos
kubectl get events -n homelab --sort-by='.lastTimestamp'
```

**PVC no se enlaza**
```bash
# Verificar PV disponibles
kubectl get pv

# Verificar StorageClass
kubectl get storageclass
```

**No se puede acceder a servicio**
```bash
# Verificar ingress
kubectl get ingress -n homelab

# Verificar servicio
kubectl get svc -n homelab

# Test DNS interno
kubectl run test-pod --image=busybox -it --rm -- nslookup plex.homelab.svc.cluster.local
```

### Comandos Útiles

```bash
# Reiniciar deployment
kubectl rollout restart deployment/<app> -n homelab

# Ver historial de rollout
kubectl rollout history deployment/<app> -n homelab

# Rollback a versión anterior
kubectl rollout undo deployment/<app> -n homelab

# Ejecutar shell en pod
kubectl exec -it -n homelab <pod-name> -- /bin/bash
```

## 📝 Contribuciones

¡Las contribuciones son bienvenidas! Por favor:

1. Fork el proyecto
2. Crea tu feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la branch (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT - ver el archivo [LICENSE](LICENSE) para detalles.

## 🙏 Agradecimientos

- Comunidad K3s y Kubernetes
- Desarrolladores de todas las aplicaciones incluidas
- Comunidad r/selfhosted y r/homelab

---

<div align="center">
Made with ❤️ for the homelab community
</div>