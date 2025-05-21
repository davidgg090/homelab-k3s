# Home Lab en Kubernetes (K3s) 🦀

Este repositorio contiene los manifiestos de Kubernetes y la configuración para desplegar mi Home Lab personal en un clúster K3s de un solo nodo, ejecutándose en un Mini PC con Ubuntu Server. El objetivo es tener un entorno de servicios auto-alojados robusto, gestionado de forma declarativa y con la posibilidad de CI/CD.

## ✨ Servicios Desplegados

Actualmente, este repositorio configura los siguientes servicios:

* **Gestión de Medios:**
    * Plex Media Server
    * Jellyfin
    * Sonarr (Gestor de Series)
    * Radarr (Gestor de Películas)
    * Bazarr (Gestor de Subtítulos)
    * Overseerr (Solicitudes de Medios)
* **Descargas:**
    * qBittorrent (Cliente BitTorrent)
    * Jackett (Proxy de Indexadores)
* **Bases de Datos:**
    * PostgreSQL
    * MongoDB
* **Utilidades y Panel de Control:**
    * Homepage (Panel de control personalizable)
    * Docker Registry (Registro Docker local privado)
* **Monitoreo:**
    * Prometheus (Recolección de métricas)
    * Grafana (Visualización de métricas y dashboards)
* **Gestión del Clúster:**
    * Traefik (Ingress Controller por defecto en K3s)
    * K9s (Recomendado para gestión vía terminal)

##  Architectural Overview

* **Orquestador:** K3s en un Mini PC con Ubuntu Server.
* **Almacenamiento Persistente:**
    * **Medios:** Disco Duro USB externo montado en `/mnt/usbmedia` en el host, accedido vía `hostPath` PersistentVolumes.
    * **Configuraciones y Bases de Datos:**
        * Algunas configuraciones críticas y bases de datos usan `hostPath` PersistentVolumes en el SSD interno del Mini PC (bajo `/mnt/homelab_config`).
        * Otras configuraciones de aplicaciones usan `PersistentVolumeClaim` con el `StorageClass` `local-path` de K3s (almacenadas en `/var/lib/rancher/k3s/storage/` en el SSD interno).
* **Acceso a Servicios:**
    * Los servicios web se exponen a la red local a través de Traefik Ingress, usando nombres de host locales (ej. `plex.homelab.local`). Se requiere configuración de DNS local.
    * Algunos servicios (como qBittorrent P2P) usan `NodePort` para exposición directa.
* **Seguridad:**
    * Firewall UFW configurado en el servidor host.
    * NetworkPolicies para controlar el tráfico entre Pods dentro del clúster.

## 🚀 Requisitos Previos del Servidor Host

Antes de desplegar los manifiestos de este repositorio, el servidor host (Mini PC con Ubuntu Server) debe estar configurado de la siguiente manera:

1.  **Ubuntu Server LTS** instalado.
2.  **Acceso SSH** configurado (preferiblemente con llaves).
3.  **IP Estática** o reserva DHCP para el servidor.
4.  **Disco Duro USB para Medios:** Montado automáticamente en `/mnt/usbmedia` vía `/etc/fstab` (usando UUID).
5.  **Directorios para `hostPath` PVs Creados:**
    * `/mnt/usbmedia` (con subcarpetas `tv`, `movies`, `downloads`)
    * `/mnt/homelab_config` (con subcarpetas `databases/postgresql`, `databases/mongodb`, `registry-data`, etc.)
    * Permisos y propiedad de estos directorios establecidos para el PUID/PGID `1000:1000` (o el que se use en los manifiestos).
6.  **K3s Instalado:**
    ```bash
    curl -sfL [https://get.k3s.io](https://get.k3s.io) | INSTALL_K3S_EXEC="--disable=servicelb" sh -s -
    ```
7.  **`kubectl` Configurado** para el usuario no root.
8.  **Firewall (UFW) Configurado** para permitir SSH, Traefik (80, 443) y los NodePorts necesarios desde la red local.
9.  **(Opcional) Configuración de K3s para Registro Inseguro:** Si se usa el Docker Registry local, `/etc/rancher/k3s/registries.yaml` debe estar configurado.
10. **(Opcional) Helm v3 Instalado** si se va a desplegar `kube-prometheus-stack` manualmente desde el servidor.

## 📁 Estructura del Repositorio

* `.github/workflows/`: Contiene los flujos de trabajo de GitHub Actions para CI/CD.
* `kubernetes/`: Directorio principal para todos los manifiestos de Kubernetes.
    * `00-base/`: Namespace, ConfigMap común, plantilla de Secrets.
    * `01-storage/`: PersistentVolumes (`hostPath`) y PersistentVolumeClaims globales.
    * `02-apps/`: Subdirectorios para cada aplicación, conteniendo sus Deployments, Services, Ingresses, y PVCs específicos.
    * `03-monitoring/`: Configuración para `kube-prometheus-stack` (values.yaml).
    * `04-network-policies/`: Políticas de Red para el namespace `homelab`.
    * `kustomization.yaml`: (Opcional) Para despliegues con `kubectl apply -k .`.
* `.gitignore`: Especifica los archivos que Git debe ignorar.
* `README.md`: Este archivo.

## 🛠️ Despliegue Manual Inicial

1.  **Clonar el Repositorio en el Servidor K3s:**
    ```bash
    git clone [https://github.com/TU_USUARIO_GITHUB/TU_REPOSITORIO.git](https://github.com/TU_USUARIO_GITHUB/TU_REPOSITORIO.git)
    cd TU_REPOSITORIO/kubernetes/
    ```
2.  **Preparar Secretos:**
    * Copia `00-base/secrets.template.yaml` a `00-base/secrets.yaml`.
    * Edita `00-base/secrets.yaml` y **reemplaza todos los placeholders con tus contraseñas y tokens reales.** ¡No hagas commit de este archivo con secretos reales!
3.  **Aplicar Manifiestos en Orden:**
    * **Base:**
        ```bash
        kubectl apply -f 00-base/namespace.yaml
        kubectl apply -f 00-base/common-configmap.yaml
        kubectl apply -f 00-base/secrets.yaml # ¡El que tiene los secretos reales!
        ```
    * **Almacenamiento:**
        ```bash
        kubectl apply -f 01-storage/hostpath-pvs.yaml
        kubectl apply -f 01-storage/global-pvcs.yaml
        # Aplicar PVCs específicos de aplicaciones (ej. kubernetes/02-apps/plex/pvc.yaml, etc.)
        find kubernetes/02-apps -name 'pvc.yaml' -exec kubectl apply -f {} \;
        ```
        Verifica: `kubectl get pvc -n homelab` (deben estar `Bound`).
    * **(Crítico) Copiar Datos de Configuración Existentes:** Si estás migrando, este es el momento de copiar tus datos de configuración a las rutas físicas de los PVCs `local-path` (en `/var/lib/rancher/k3s/storage/...`).
    * **Aplicaciones:**
        ```bash
        kubectl apply -R -f 02-apps/ # Aplica recursivamente todo en 02-apps
        ```
    * **Políticas de Red (¡Con Cuidado!):**
        Aplica primero las políticas de permiso:
        ```bash
        kubectl apply -f 04-network-policies/01-allow-dns.yaml
        kubectl apply -f 04-network-policies/02-allow-ingress-traffic.yaml
        kubectl apply -f 04-network-policies/03-app-to-app-communication.yaml
        kubectl apply -f 04-network-policies/04-allow-monitoring.yaml
        ```
        Verifica la comunicación. Luego, si todo está bien:
        ```bash
        kubectl apply -f 04-network-policies/00-default-deny-all.yaml
        ```
    * **Monitoreo (Helm):**
        ```bash
        # Asegúrate que el namespace monitoring exista o usa --create-namespace
        kubectl apply -f 03-monitoring/namespace.yaml 
        helm upgrade --install prometheus prometheus-community/kube-prometheus-stack \
          --namespace monitoring \
          -f 03-monitoring/kube-prometheus-stack-values.yaml \
          --atomic
        ```
4.  **Configurar DNS Local:**
    Asegúrate de que los hosts definidos en tus Ingresses (ej. `plex.homelab.local`) resuelvan a la IP de tu servidor K3s.

## 🔄 CI/CD con GitHub Actions (Visión General)

El archivo `.github/workflows/deploy.yaml` (aún por crear en detalle) tiene como objetivo automatizar el despliegue:
1.  Se activa en un `push` a la rama `main`.
2.  Utiliza un **self-hosted runner** en el servidor K3s.
3.  Extrae el código.
4.  Prepara el archivo `secrets.yaml` usando **GitHub Secrets**.
5.  Configura `kubectl` usando un `kubeconfig` almacenado como un GitHub Secret.
6.  Aplica los manifiestos (ej. `kubectl apply -k kubernetes/` o aplicando directorios específicos).

## 🔧 Mantenimiento y Actualizaciones

* **Aplicaciones:** Actualiza las etiquetas de imagen en los archivos `deployment.yaml` o `statefulset.yaml` y haz `git push`. CI/CD debería aplicar los cambios. Manualmente: `kubectl rollout restart deployment <nombre-deployment> -n homelab`.
* **K3s:** Sigue la documentación oficial de K3s para actualizaciones.
* **Helm Charts:** Usa `helm upgrade` con el archivo de valores actualizado.

## 💡 Contribuciones y Mejoras

¡Este es un proyecto personal, pero las sugerencias son bienvenidas! (Opcional, si planeas hacerlo público).
