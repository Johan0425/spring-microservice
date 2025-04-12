# Product Management Service

Este proyecto es una aplicación Spring Boot que proporciona una API RESTful para la gestión de productos. Implementa operaciones CRUD (Crear, Leer, Actualizar, Eliminar) para entidades de producto y está diseñado para funcionar con una base de datos MariaDB en un entorno containerizado con Docker.

## Requisitos

- Java 17 o superior
- Gradle 8.x
- Docker y Docker Compose
- MariaDB

## Estructura del Proyecto

```
demo/
├── src/
│   ├── main/
│   │   ├── java/
│   │   │   └── com/
│   │   │       └── example/
│   │   │           └── demo/
│   │   │               ├── controller/
│   │   │               │   └── ProductController.java
│   │   │               ├── model/
│   │   │               │   └── Product.java
│   │   │               ├── repository/
│   │   │               │   └── ProductRepository.java
│   │   │               ├── service/
│   │   │               │   └── ProductService.java
│   │   │               └── DemoApplication.java
│   │   └── resources/
│   │       └── application.properties
│   └── test/
│       └── java/
│           └── com/
│               └── example/
│                   └── demo/
│                       ├── controller/
│                       │   └── ProductControllerTest.java
│                       ├── integration/
│                       │   └── ProductIntegrationTest.java
│                       └── DemoApplicationTests.java
├── build.gradle
├── docker-compose.yml
├── Dockerfile
└── scripts/
    ├── build.sh
    ├── backup_db.sh
    └── eval_partial.sh
```

## Configuración

### Base de Datos

La aplicación está configurada para conectarse a una base de datos MariaDB. La configuración se encuentra en `src/main/resources/application.properties`:

```properties
spring.datasource.url=jdbc:mariadb://mariadb:3306/demodb
spring.datasource.username=root
spring.datasource.password=rootpassword
spring.datasource.driver-class-name=org.mariadb.jdbc.Driver

spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=true
spring.jpa.properties.hibernate.dialect=org.hibernate.dialect.MariaDBDialect

server.port=8080
```

### Pruebas

Para las pruebas, se recomienda usar H2 como base de datos en memoria. Crea un archivo `src/test/resources/application-test.properties` con el siguiente contenido:

```properties
spring.datasource.url=jdbc:h2:mem:testdb
spring.datasource.driver-class-name=org.h2.Driver
spring.datasource.username=sa
spring.datasource.password=
spring.jpa.database-platform=org.hibernate.dialect.H2Dialect
spring.jpa.hibernate.ddl-auto=create-drop
```

Y asegúrate de anotar tus clases de prueba con `@ActiveProfiles("test")`.

## Construcción y Ejecución

### Usando Gradle directamente

```bash
# Compilar el proyecto
./gradlew clean build

# Ejecutar la aplicación
./gradlew bootRun
```

### Usando Docker

```bash
# Construir la imagen Docker
docker build -t product-service .

# Ejecutar con Docker Compose
docker-compose up -d
```

Alternativamente, puedes usar el script proporcionado:

```bash
./scripts/build.sh
```

## API Endpoints

La aplicación expone los siguientes endpoints:

- `GET /api/products`: Obtiene todos los productos
- `GET /api/products/{id}`: Obtiene un producto por ID
- `POST /api/products`: Crea un nuevo producto
- `PUT /api/products/{id}`: Actualiza un producto existente
- `DELETE /api/products/{id}`: Elimina un producto

## Solución de Problemas

### Errores de Conexión a la Base de Datos

Si encuentras errores como `UnknownHostException` durante las pruebas, asegúrate de:

1. Tener el contenedor de Docker de MariaDB en ejecución
2. Usar el perfil de prueba con H2 para las pruebas unitarias e integración

### Errores de Importación en el IDE

Si el IDE muestra errores sobre las importaciones de Jakarta Persistence:

1. Actualiza/sincroniza el proyecto Gradle en tu IDE
2. Limpia la caché del IDE
3. Asegúrate de tener las extensiones correctas instaladas (para VS Code)

## Licencia

Este proyecto está licenciado bajo la Licencia MIT - ver el archivo [LICENSE](LICENSE) para más detalles.