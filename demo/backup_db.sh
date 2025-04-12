#!/bin/bash

# Definir variables
CONTAINER_NAME="mariadb"
BACKUP_DIR="."
DATE=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="backup_${DATE}.sql"

# Colores para output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}=========================================${NC}"
echo -e "${YELLOW}=       BACKUP DE BASE DE DATOS         =${NC}"
echo -e "${YELLOW}=========================================${NC}"

echo -e "${YELLOW}Verificando si el contenedor MariaDB está en ejecución...${NC}"
if ! docker ps | grep -q "$CONTAINER_NAME"; then
    echo -e "${RED}El contenedor $CONTAINER_NAME no está en ejecución.${NC}"
    exit 1
fi

echo -e "${YELLOW}Creando backup de la base de datos...${NC}"
if docker exec $CONTAINER_NAME mysqldump -u root -prootpassword demodb > "${BACKUP_DIR}/${BACKUP_FILE}"; then
    echo -e "${GREEN}✓ Backup creado exitosamente: ${BACKUP_FILE}${NC}"
    echo -e "${YELLOW}Tamaño del backup:${NC} $(du -h ${BACKUP_DIR}/${BACKUP_FILE} | cut -f1)"
else
    echo -e "${RED}✗ Error al crear el backup.${NC}"
    exit 1
fi

echo -e "${YELLOW}=========================================${NC}"
echo -e "${GREEN}Backup completado: $(date)${NC}"
echo -e "${YELLOW}=========================================${NC}"
