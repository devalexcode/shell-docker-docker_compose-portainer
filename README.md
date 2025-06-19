# Instalación Automática de Docker y Portainer

Este repositorio proporciona un script Bash (`install.sh`) para instalar y configurar Docker, Docker Compose plugin y Portainer en servidores basados en Ubuntu.

## Requisitos previos

- Sistema operativo: Ubuntu 18.04, 20.04, 22.04, 24.04 (u otra versión compatible con los repositorios oficiales de Docker)
- Acceso con usuario que tenga privilegios de sudo
- Conexión a Internet desde el servidor

## Contenido del repositorio

- `install.sh`: script que automatiza la instalación.

## Uso

1. **Descargar o clonar el repositorio**

   ```bash
   git clone https://github.com/devalexcode/shell-docker-docker_compose-portainer.git
   cd shell-docker-docker_compose-portainer
   ```

2. **Dar permisos de ejecución al script**

   ```bash
   chmod +x install.sh
   ```

3. **Ejecutar el script**

   ```bash
   ./install.sh
   ```

   - El script actualizará el sistema, instalará Docker y sus herramientas, añadirá el usuario al grupo `docker` y desplegará Portainer.
   - Al finalizar, verás un mensaje indicando la URL de acceso a Portainer:

     ```
     Portainer instalado y accesible en: http://<IP_DEL_SERVIDOR>:9000
     ```

## Personalización

- **Puertos**: El script expone Portainer en los puertos `9000` (UI web) y `8000` (API interna). Para cambiarlos, edita las opciones `-p` en la sección de `docker run`.
- **Datos persistentes**: El volumen `portainer_data` se crea automáticamente. Para cambiar la ubicación, ajusta la definición de volumen y la opción `-v`.

¡Listo! Con estos pasos tu servidor quedará preparado para gestionar contenedores Docker a través de Portainer.

## 👨‍💻 Autor

Desarrollado por [Alejandro Robles | Devalex ](http://devalexcode.com)  
¿Necesitas que lo haga por ti? ¡Estoy para apoyarte! 🤝 https://devalexcode.com/soluciones/instalacion-de-portainer-en-servidor-vps

¿Dudas o sugerencias? ¡Contribuciones bienvenidas!
