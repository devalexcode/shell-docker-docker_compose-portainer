#!/usr/bin/env bash
set -euo pipefail

# Colores ANSI
GREEN='\033[0;32m'
NC='\033[0m' # No Color (reset)

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
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" |
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

# Instalar Portainer
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

echo "Portainer instalado y accesible en: http://$(hostname -I | awk '{print $1}'):9000"

# Mensaje final
echo "¡Instalación completada! Comprueba con: docker --version, docker compose version y accede a Portainer en el navegador."

newgrp docker
