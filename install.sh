#!/usr/bin/env bash
set -euo pipefail

# Colores ANSI
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color (reset)

# Obtener IP pública (global)
PUBLIC_IP=$(curl -s http://checkip.amazonaws.com || curl -s https://icanhazip.com)
export PUBLIC_IP

# Función para validar que un puerto esté en escucha local y accesible externamente para una aplicación
# Recibe Puerto y Nombre de la Aplicación
# Si falla alguna comprobación, muestra mensaje de error y termina el script
check_port_open() {
  local PORT=$1
  local APP_NAME=$2

  # Verificar accesibilidad externa
  if ! nc -z -w5 "${PUBLIC_IP}" "${PORT}"; then
    echo -e "${RED}Error: El puerto ${PORT} para ${APP_NAME} no es accesible externamente en ${PUBLIC_IP}:${PORT}. Verifica las reglas de entrada de tu proveedor de VPS.${NC}"
    exit 1
  fi

  echo -e "${GREEN}¡Instalación completada! ${APP_NAME} funcionando y accesible: http://${PUBLIC_IP}:${PORT}.${NC}"
}

# Actualizar repositorios y paquetes
sudo apt update && sudo apt upgrade -y

# Instalar prerequisitos
sudo apt install -y \
  apt-transport-https \
  ca-certificates \
  curl \
  gnupg \
  lsb-release

# ─────────────────────────────────────────────────────────────────────────────
# Instalación de Docker (si no está instalado)
# ─────────────────────────────────────────────────────────────────────────────
if ! command -v docker >/dev/null 2>&1; then
  echo "Docker no encontrado. Instalando Docker..."
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg |
    sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] \
    https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" |
    sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
  sudo apt update && sudo apt install -y docker-ce docker-ce-cli containerd.io
  sudo systemctl enable --now docker
  sudo usermod -aG docker "$USER"
  echo -e "${GREEN}Docker instalado: $(docker --version)${NC}"
else
  echo "Docker ya está instalado: $(docker --version)"
fi

# ─────────────────────────────────────────────────────────────────────────────
# Instalación de Docker Compose CLI plugin (si no está instalado)
# ─────────────────────────────────────────────────────────────────────────────
if ! docker compose version >/dev/null 2>&1; then
  echo "Docker Compose CLI plugin no encontrado. Instalando..."
  sudo apt-get install -y docker-compose-plugin
  echo -e "${GREEN}Docker Compose instalado: $(docker compose version)${NC}"
else
  echo "Docker Compose ya está instalado: $(docker compose version)"
fi

# ─────────────────────────────────────────────────────────────────────────────
# Instalación y configuración de Portainer
# ─────────────────────────────────────────────────────────────────────────────
if sudo docker container inspect portainer >/dev/null 2>&1; then
  echo "Portainer ya está instalado y configurado."
else
  echo "Instalando Portainer..."
  sudo docker volume create portainer_data
  sudo docker run -d \
    --name portainer \
    --restart=always \
    -p 8000:8000 \
    -p 9000:9000 \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v portainer_data:/data \
    portainer/portainer-ce

  sudo docker restart portainer
  echo -e "${GREEN}Portainer instalado y contenedores iniciados.${NC}"
fi

# Aplicar cambios de grupo sin necesidad de reiniciar sesión
newgrp docker

# Validación post-instalación (asegurar que los puertos accesibles)
check_port_open 9000 "Portainer"
