// ProductIntegrationTest.java
package com.example.demo.integration;

import com.example.demo.model.Product;
import com.example.demo.repository.ProductRepository;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.boot.test.web.server.LocalServerPort;
import org.springframework.http.*;

import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
public class ProductIntegrationTest {

    @LocalServerPort
    private int port;

    @Autowired
    private TestRestTemplate restTemplate;

    @Autowired
    private ProductRepository productRepository;

    private String baseUrl;

    @BeforeEach
    public void setUp() {
        baseUrl = "http://localhost:" + port + "/api/products";
        // Limpiar la base de datos antes de cada prueba
        productRepository.deleteAll();
    }

    @AfterEach
    public void tearDown() {
        // Limpiar la base de datos después de cada prueba
        productRepository.deleteAll();
    }

    @Test
    public void testCRUDOperations() {
        // Preparar un producto para las pruebas
        Product testProduct = new Product("Test Product", "Test Description", 25.99, 5);

        // CREATE - Crear un producto
        ResponseEntity<Product> createResponse = restTemplate.postForEntity(
                baseUrl,
                testProduct,
                Product.class
        );
        assertEquals(HttpStatus.CREATED, createResponse.getStatusCode());
        Product createdProduct = createResponse.getBody();
        assertNotNull(createdProduct);
        assertNotNull(createdProduct.getId());
        assertEquals("Test Product", createdProduct.getName());

        // READ - Leer el producto creado
        ResponseEntity<Product> getResponse = restTemplate.getForEntity(
                baseUrl + "/" + createdProduct.getId(),
                Product.class
        );
        assertEquals(HttpStatus.OK, getResponse.getStatusCode());
        Product retrievedProduct = getResponse.getBody();
        assertNotNull(retrievedProduct);
        assertEquals(createdProduct.getId(), retrievedProduct.getId());

        // UPDATE - Actualizar el producto
        retrievedProduct.setName("Updated Product");
        retrievedProduct.setPrice(30.99);
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        HttpEntity<Product> requestUpdate = new HttpEntity<>(retrievedProduct, headers);
        
        ResponseEntity<Product> updateResponse = restTemplate.exchange(
                baseUrl + "/" + retrievedProduct.getId(),
                HttpMethod.PUT,
                requestUpdate,
                Product.class
        );
        assertEquals(HttpStatus.OK, updateResponse.getStatusCode());
        Product updatedProduct = updateResponse.getBody();
        assertNotNull(updatedProduct);
        assertEquals("Updated Product", updatedProduct.getName());
        assertEquals(30.99, updatedProduct.getPrice());

        // READ ALL - Leer todos los productos
        ResponseEntity<List> getAllResponse = restTemplate.getForEntity(
                baseUrl,
                List.class
        );
        assertEquals(HttpStatus.OK, getAllResponse.getStatusCode());
        List<Product> allProducts = getAllResponse.getBody();
        assertNotNull(allProducts);
        assertEquals(1, allProducts.size());

        // DELETE - Eliminar el producto
        restTemplate.delete(baseUrl + "/" + createdProduct.getId());
        
        // Verificar que se haya eliminado
        ResponseEntity<Product> verifyDeleteResponse = restTemplate.getForEntity(
                baseUrl + "/" + createdProduct.getId(),
                Product.class
        );
        assertEquals(HttpStatus.NOT_FOUND, verifyDeleteResponse.getStatusCode());
    }
}