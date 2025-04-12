#!/bin/bash

# Colores para output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Variables
APP_NAME="microservicio-springboot"
DOCKER_USERNAME="joanpe"

echo -e "${YELLOW}=========================================${NC}"
echo -e "${YELLOW}=   CONSTRUCCIÓN Y EJECUCIÓN AUTOMÁTICA  =${NC}"
echo -e "${YELLOW}=========================================${NC}"

# Verificar si hay cambios en Git
echo -e "${YELLOW}Verificando cambios en Git...${NC}"
if git status --porcelain | grep -q .; then
    echo -e "${GREEN}Se detectaron cambios en el código fuente.${NC}"
    CHANGES_DETECTED=true
else
    echo -e "${YELLOW}No se detectaron cambios en el código fuente.${NC}"
    CHANGES_DETECTED=false
fi

# Detener contenedores existentes
echo -e "${YELLOW}Deteniendo contenedores existentes...${NC}"
docker-compose down

# Si hay cambios o se fuerza la construcción, reconstruir la imagen
if [ "$CHANGES_DETECTED" = true ] || [ "$1" = "--force" ]; then
    echo -e "${YELLOW}Construyendo la aplicación...${NC}"
    ./gradlew clean build -x test

    if [ $? -ne 0 ]; then
        echo -e "${RED}Error al compilar la aplicación.${NC}"
        exit 1
    fi

    echo -e "${YELLOW}Construyendo imagen Docker...${NC}"
    docker build -t ${DOCKER_USERNAME}/${APP_NAME} .

    if [ $? -ne 0 ]; then
        echo -e "${RED}Error al construir la imagen Docker.${NC}"
        exit 1
    fi

    echo -e "${GREEN}✓ Imagen Docker construida exitosamente.${NC}"

    # Subir la imagen a Docker Hub (opcional)
    if [ "$1" = "--push" ] || [ "$2" = "--push" ]; then
        echo -e "${YELLOW}Subiendo imagen a Docker Hub...${NC}"
        docker push ${DOCKER_USERNAME}/${APP_NAME}
        
        if [ $? -ne 0 ]; then
            echo -e "${RED}Error al subir la imagen a Docker Hub.${NC}"
        else
            echo -e "${GREEN}✓ Imagen subida a Docker Hub exitosamente.${NC}"
        fi
    fi
else
    echo -e "${YELLOW}No se requiere reconstruir la imagen.${NC}"
fi

# Iniciar los contenedores
echo -e "${YELLOW}Iniciando contenedores...${NC}"
docker-compose up -d

if [ $? -ne 0 ]; then
    echo -e "${RED}Error al iniciar los contenedores.${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Contenedores iniciados exitosamente.${NC}"

# Verificar el estado de los contenedores
echo -e "${YELLOW}Verificando estado de los contenedores...${NC}"
sleep 10

if docker ps | grep -q "app" && docker ps | grep -q "mariadb"; then
    echo -e "${GREEN}✓ Todos los contenedores están en ejecución.${NC}"
else
    echo -e "${RED}✗ Algunos contenedores no están en ejecución. Revisa 'docker ps'.${NC}"
fi

# Mostrar los puertos mapeados
echo -e "${YELLOW}Puertos mapeados:${NC}"
docker ps --format "table {{.Names}}\t{{.Ports}}"

echo -e "${YELLOW}=========================================${NC}"
echo -e "${GREEN}Construcción y ejecución completada: $(date)${NC}"
echo -e "${YELLOW}=========================================${NC}"

echo -e "${YELLOW}Para ejecutar el script de evaluación del parcial, utilice:${NC}"
echo -e "${GREEN}./eval_partial.sh${NC}"
