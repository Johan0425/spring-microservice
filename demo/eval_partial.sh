#!/bin/bash

# Colores para output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Variables de puntuación
TOTAL_POINTS=0
MAX_POINTS=100

# Función para evaluar criterios y sumar puntos
evaluate() {
  local criterion=$1
  local max_points=$2
  local result=$3
  local points=$4
  
  if [ "$result" == "PASS" ]; then
    echo -e "${GREEN}✓ $criterion: APROBADO${NC} ($points/$max_points pts)"
    TOTAL_POINTS=$((TOTAL_POINTS + points))
  else
    echo -e "${RED}✗ $criterion: FALLIDO${NC} (0/$max_points pts)"
  fi
}

echo -e "${YELLOW}=========================================${NC}"
echo -e "${YELLOW}= EVALUACIÓN DE PARCIAL 2 - SPRING BOOT =${NC}"
echo -e "${YELLOW}=========================================${NC}"

# 1. Verificar si los contenedores están corriendo
echo -e "\n${YELLOW}Verificando contenedores Docker...${NC}"
if docker ps | grep -q "app"; then
  DOCKER_APP="PASS"
else
  DOCKER_APP="FAIL"
fi

if docker ps | grep -q "mariadb"; then
  DOCKER_DB="PASS"
else
  DOCKER_DB="FAIL"
fi

evaluate "Contenedor de la aplicación Spring Boot" 5 "$DOCKER_APP" 5
evaluate "Contenedor de MariaDB" 5 "$DOCKER_DB" 5

# 2. Verificar endpoints CRUD
echo -e "\n${YELLOW}Verificando endpoints CRUD...${NC}"

# Crear un producto
echo "Creando producto de prueba..."
CREATE_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" -X POST -H "Content-Type: application/json" -d '{"name":"Producto Test","description":"Descripción del producto","price":99.99,"stock":10}' http://localhost:8080/api/products)

if [ "$CREATE_RESPONSE" == "201" ]; then
  CREATE_TEST="PASS"
else
  CREATE_TEST="FAIL"
fi

# Obtener el ID del producto creado
PRODUCT_ID=$(curl -s -X POST -H "Content-Type: application/json" -d '{"name":"Producto Test","description":"Descripción del producto","price":99.99,"stock":10}' http://localhost:8080/api/products | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f2)

# Leer un producto
if [ -n "$PRODUCT_ID" ]; then
  READ_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" -X GET http://localhost:8080/api/products/$PRODUCT_ID)
  if [ "$READ_RESPONSE" == "200" ]; then
    READ_TEST="PASS"
  else
    READ_TEST="FAIL"
  fi
else
  READ_TEST="FAIL"
fi

# Actualizar un producto
if [ -n "$PRODUCT_ID" ]; then
  UPDATE_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" -X PUT -H "Content-Type: application/json" -d '{"name":"Producto Actualizado","description":"Descripción actualizada","price":129.99,"stock":15}' http://localhost:8080/api/products/$PRODUCT_ID)
  if [ "$UPDATE_RESPONSE" == "200" ]; then
    UPDATE_TEST="PASS"
  else
    UPDATE_TEST="FAIL"
  fi
else
  UPDATE_TEST="FAIL"
fi

# Eliminar un producto
if [ -n "$PRODUCT_ID" ]; then
  DELETE_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" -X DELETE http://localhost:8080/api/products/$PRODUCT_ID)
  if [ "$DELETE_RESPONSE" == "204" ]; then
    DELETE_TEST="PASS"
  else
    DELETE_TEST="FAIL"
  fi
else
  DELETE_TEST="FAIL"
fi

evaluate "Endpoint CREATE" 4 "$CREATE_TEST" 4
evaluate "Endpoint READ" 3 "$READ_TEST" 3
evaluate "Endpoint UPDATE" 4 "$UPDATE_TEST" 4
evaluate "Endpoint DELETE" 4 "$DELETE_TEST" 4

# 3. Verificar la arquitectura en capas
echo -e "\n${YELLOW}Verificando arquitectura en capas...${NC}"

# Verificar existencia de archivos de cada capa
if [ -f "./src/main/java/com/example/demo/controller/ProductController.java" ]; then
  CONTROLLER_LAYER="PASS"
else
  CONTROLLER_LAYER="FAIL"
fi

if [ -f "./src/main/java/com/example/demo/service/ProductService.java" ]; then
  SERVICE_LAYER="PASS"
else
  SERVICE_LAYER="FAIL"
fi

if [ -f "./src/main/java/com/example/demo/repository/ProductRepository.java" ]; then
  REPOSITORY_LAYER="PASS"
else
  REPOSITORY_LAYER="FAIL"
fi

if [ -f "./src/main/java/com/example/demo/model/Product.java" ]; then
  MODEL_LAYER="PASS"
else
  MODEL_LAYER="FAIL"
fi

evaluate "Capa de Controladores" 5 "$CONTROLLER_LAYER" 5
evaluate "Capa de Servicios" 5 "$SERVICE_LAYER" 5
evaluate "Capa de Repositorios" 5 "$REPOSITORY_LAYER" 5
evaluate "Capa de Modelos" 5 "$MODEL_LAYER" 5

# 4. Verificar pruebas unitarias e integración
echo -e "\n${YELLOW}Verificando pruebas...${NC}"

# Ejecutar pruebas con Gradle
echo "Ejecutando pruebas..."
./gradlew test jacocoTestReport > /dev/null 2>&1

if [ -f "./build/reports/tests/test/index.html" ]; then
  UNIT_TESTS="PASS"
else
  UNIT_TESTS="FAIL"
fi

if [ -f "./build/reports/jacoco/test/html/index.html" ]; then
  COVERAGE_REPORT="PASS"
else
  COVERAGE_REPORT="FAIL"
fi

evaluate "Pruebas unitarias" 5 "$UNIT_TESTS" 5
evaluate "Informe de cobertura JaCoCo" 5 "$COVERAGE_REPORT" 5

# 5. Verificar configuración de Docker
echo -e "\n${YELLOW}Verificando configuración de Docker...${NC}"

if [ -f "./Dockerfile" ]; then
  # Verificar si el Dockerfile usa multi-stage
  if grep -q "FROM.*AS.*build" "./Dockerfile" && grep -q "COPY.*--from=build" "./Dockerfile"; then
    DOCKERFILE_MULTISTAGE="PASS"
  else
    DOCKERFILE_MULTISTAGE="FAIL"
  fi
else
  DOCKERFILE_MULTISTAGE="FAIL"
fi

if [ -f "./docker-compose.yml" ]; then
  DOCKER_COMPOSE="PASS"
else
  DOCKER_COMPOSE="FAIL"
fi

if [ -f "./.dockerignore" ]; then
  DOCKERIGNORE="PASS"
else
  DOCKERIGNORE="FAIL"
fi

evaluate "Dockerfile con multi-stage build" 5 "$DOCKERFILE_MULTISTAGE" 5
evaluate "Docker Compose configurado" 5 "$DOCKER_COMPOSE" 5
evaluate "Archivo .dockerignore" 5 "$DOCKERIGNORE" 5

# 6. Verificar persistencia de datos y backup
echo -e "\n${YELLOW}Verificando persistencia y backup de datos...${NC}"

# Verificar si existe el volumen de persistencia
if docker volume ls | grep -q "mariadb-data"; then
  PERSISTENT_VOLUME="PASS"
else
  PERSISTENT_VOLUME="FAIL"
fi

# Verificar si existe el script de backup
if [ -f "./backup_db.sh" ]; then
  BACKUP_SCRIPT="PASS"
  
  # Ejecutar backup
  echo "Ejecutando backup de base de datos..."
  chmod +x ./backup_db.sh
  ./backup_db.sh > /dev/null 2>&1
  
  # Verificar si se creó el archivo de backup con fecha
  if ls ./backup_*.sql 1> /dev/null 2>&1; then
    BACKUP_CREATED="PASS"
  else
    BACKUP_CREATED="FAIL"
  fi
else
  BACKUP_SCRIPT="FAIL"
  BACKUP_CREATED="FAIL"
fi

evaluate "Volumen persistente configurado" 5 "$PERSISTENT_VOLUME" 5
evaluate "Script de backup disponible" 5 "$BACKUP_SCRIPT" 5
evaluate "Backup creado correctamente" 5 "$BACKUP_CREATED" 5

# 7. Verificar colección Postman
echo -e "\n${YELLOW}Verificando colección Postman...${NC}"

if [ -f "./ProductsAPI.postman_collection.json" ]; then
  POSTMAN_COLLECTION="PASS"
else
  POSTMAN_COLLECTION="FAIL"
fi

evaluate "Colección Postman disponible" 10 "$POSTMAN_COLLECTION" 10

# 8. Verificar publicación en Docker Hub
echo -e "\n${YELLOW}Verificando publicación en Docker Hub...${NC}"

# Obtener nombre de usuario desde .env o configuración
USERNAME=$(grep -o 'DOCKER_USERNAME=.*' .env 2>/dev/null | cut -d'=' -f2)
if [ -z "$USERNAME" ]; then
  # Si no hay .env, intentar extraer de otros lugares
  USERNAME=$(grep -o 'image:.*/' docker-compose.yml 2>/dev/null | cut -d'/' -f1 | tr -d ' ' | cut -d':' -f2)
fi

if [ -n "$USERNAME" ]; then
  # Verificar si la imagen está en Docker Hub
  DOCKER_HUB_CHECK=$(curl -s "https://hub.docker.com/v2/repositories/$USERNAME/" | grep -o "\"name\":\"[^\"]*\"" | wc -l)
  
  if [ "$DOCKER_HUB_CHECK" -gt 0 ]; then
    DOCKER_HUB_PUBLISHED="PASS"
  else
    DOCKER_HUB_PUBLISHED="FAIL"
  fi
else
  DOCKER_HUB_PUBLISHED="FAIL"
fi

evaluate "Imagen publicada en Docker Hub" 5 "$DOCKER_HUB_PUBLISHED" 5

# 9. Verificar script de automatización (BONUS)
echo -e "\n${YELLOW}Verificando script de automatización (BONUS)...${NC}"

if [ -f "./build_and_run.sh" ]; then
  AUTOMATION_SCRIPT="PASS"
else
  AUTOMATION_SCRIPT="FAIL"
fi

evaluate "Script de automatización (BONUS)" 5 "$AUTOMATION_SCRIPT" 5

# Calcular puntuación final
echo -e "\n${YELLOW}=========================================${NC}"
echo -e "${YELLOW}=           PUNTUACIÓN FINAL           =${NC}"
echo -e "${YELLOW}=========================================${NC}"
echo -e "${GREEN}TOTAL: $TOTAL_POINTS / $MAX_POINTS puntos${NC}"

# Calcular porcentaje
PERCENTAGE=$((TOTAL_POINTS * 100 / MAX_POINTS))
echo -e "${GREEN}PORCENTAJE: $PERCENTAGE%${NC}"

# Determinar aprobación
if [ $PERCENTAGE -ge 80 ]; then
  echo -e "\n${GREEN}¡FELICIDADES! Has aprobado el parcial (>=80%).${NC}"
elif [ $PERCENTAGE -ge 60 ]; then
  echo -e "\n${YELLOW}Has aprobado el parcial, pero puedes mejorar (>=60%).${NC}"
else
  echo -e "\n${RED}No has aprobado el parcial (<60%). Revisa los criterios marcados como fallidos.${NC}"
fi

echo -e "\n${YELLOW}=========================================${NC}"
echo -e "${YELLOW}=              SUGERENCIAS              =${NC}"
echo -e "${YELLOW}=========================================${NC}"

# Mostrar sugerencias basadas en los criterios fallidos
if [ "$DOCKER_APP" == "FAIL" ] || [ "$DOCKER_DB" == "FAIL" ]; then
  echo -e "${RED}• Asegúrate de que los contenedores Docker estén en ejecución usando 'docker-compose up -d'${NC}"
fi

if [ "$CREATE_TEST" == "FAIL" ] || [ "$READ_TEST" == "FAIL" ] || [ "$UPDATE_TEST" == "FAIL" ] || [ "$DELETE_TEST" == "FAIL" ]; then
  echo -e "${RED}• Verifica la implementación de los endpoints REST y que respondan con los códigos HTTP correctos${NC}"
fi

if [ "$CONTROLLER_LAYER" == "FAIL" ] || [ "$SERVICE_LAYER" == "FAIL" ] || [ "$REPOSITORY_LAYER" == "FAIL" ] || [ "$MODEL_LAYER" == "FAIL" ]; then
  echo -e "${RED}• Asegúrate de implementar correctamente la arquitectura en capas${NC}"
fi

if [ "$UNIT_TESTS" == "FAIL" ] || [ "$COVERAGE_REPORT" == "FAIL" ]; then
  echo -e "${RED}• Revisa las pruebas unitarias y de integración. Asegúrate de tener suficiente cobertura${NC}"
fi

if [ "$DOCKERFILE_MULTISTAGE" == "FAIL" ] || [ "$DOCKER_COMPOSE" == "FAIL" ] || [ "$DOCKERIGNORE" == "FAIL" ]; then
  echo -e "${RED}• Revisa la configuración de Docker, asegúrate de usar multi-stage build y tener un archivo docker-compose.yml${NC}"
fi

if [ "$PERSISTENT_VOLUME" == "FAIL" ] || [ "$BACKUP_SCRIPT" == "FAIL" ] || [ "$BACKUP_CREATED" == "FAIL" ]; then
  echo -e "${RED}• Verifica la configuración del volumen persistente y el script de backup para la base de datos${NC}"
fi

if [ "$POSTMAN_COLLECTION" == "FAIL" ]; then
  echo -e "${RED}• No olvides crear y exportar una colección de Postman con todos los endpoints${NC}"
fi

if [ "$DOCKER_HUB_PUBLISHED" == "FAIL" ]; then
  echo -e "${RED}• Recuerda publicar tu imagen en Docker Hub con el formato de nombre adecuado${NC}"
fi

echo -e "\n${YELLOW}Evaluación completada: $(date)${NC}"
