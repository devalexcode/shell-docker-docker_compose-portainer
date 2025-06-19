#!/usr/bin/env bash
set -euo pipefail

# Actualizar repositorios y paquetes
sudo apt update && sudo apt upgrade -y

# Instalar prerequisitos
sudo apt install -y \
  apt-transport-https \
  ca-certificates \
  curl \
  gnupg \
  lsb-release

# Añadir la clave GPG oficial de Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
  sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Añadir el repositorio estable de Docker
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Actualizar e instalar Docker Engine y CLI
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io

# Habilitar y arrancar el servicio Docker
sudo systemctl enable docker
sudo systemctl start docker

# Añadir tu usuario al grupo 'docker' y refrescar grupo en esta sesión
sudo usermod -aG docker "$USER"
newgrp docker

# Instalar el plugin de Docker Compose
sudo apt-get install -y docker-compose-plugin

# Instalar Portainer
sudo docker volume create portainer_data
sudo docker run -d \
  --name portainer \
  --restart=always \
  -p 9000:9000 \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v portainer_data:/data \
  portainer/portainer-ce

echo "Portainer instalado y accesible en: http://$(hostname -I | awk '{print $1}'):9000"

# Mensaje final
echo "¡Instalación completada! Comprueba con: docker --version, docker compose version y accede a Portainer en el navegador."
