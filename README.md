# FlorShop API Rest

Flor Shop API Rest es una API gratuita para funcionar junto con la app en iOS llamada FlorShop que se ha desarrollado con el objetivo de poder sincronizar todos los cambios entre varios dispositivos que tengan la app. Esta API seguirá en constante evolución añadiendo funcionalidades y corrigiendo errores.
Esta API sirve como backend para una aplicación de tienda en línea, permitiendo la gestión de productos, clientes, pedidos y más. Está construida usando Swift y Vapor, proporcionando una interfaz sencilla y eficiente para la administración de la tienda.

### Requisitos mínimos
[![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg?longCache=true&style=popout-square)](https://swift.org)
[![Xcode](https://img.shields.io/badge/Xcode-12.5-blue.svg?longCache=true&style=popout-square)](https://developer.apple.com/xcode)

### ¿Que Características tiene la API?
* Maneja una Base de Datos Postgres.
* Diseñado con el popular framework VAPOR.
* Se puede desplegar en 2 contendores de Docker, 1 para la BD y otra para la API.
* Puede almacenar imágenes subidas con la app y brindar una URL que pueden usar los demás dispositivos.
* Está escrito íntegramente con Swift.
* Y muchos detalles más ...

### Rutas
* POST /session/logIn: Iniciar Sesión.
* POST /imageUrls: Crea una nueva imagen.
* GET /imageUrls/:imageId: Obtiene la imagen con el Id proporcionado (imagen).
* POST /imageUrls/sync: Listar todas las imagenes desde una fecha (se usa para sincronizar con la app).
* POST /companies: Crear nueva compañia.
* POST /companies/sync: Listar todas las compañias desde una fecha (se usa para sincronizar con la app).
* POST /subsidiaries: Crear nueva subsidiaria.
* POST /subsidiaries/sync: Listar todas las subsidiarias desde una fecha (se usa para sincronizar con la app).
* POST /employees: Crear nuevo empleado.
* POST /employees/sync: Listar todos los empleados desde una fecha (se usa para sincronizar con la app).
* POST /customers: Crear nuevo cliente.
* POST /customers/sync: Listar todos los clientes desde una fecha (se usa para sincronizar con la app).
* POST /customers/payDebt: Cancelar deuda de un cliente.
* POST /products: Crear nuevo producto.
* POST /products/sync: Listar todos los productos desde una fecha (se usa para sincronizar con la app).
* POST /sales: Crear nuevo registro de venta.
* POST /sales/sync: Listar todos las ventas desde una fecha (se usa para sincronizar con la app) (contiene también el detalle de venta).

## Ejemplos de uso

### Crear Imágen

**Request:**

```bash
POST /imageUrls
Content-Type: application/json
{
  "id": "IOS-SDW-KJSDHK-SJKAD"
  "imageUrl": "https://imagen.com"
  "imageHash": "ajshfiuahsfafqweqwfa"
  "imageData": ""
}
```

### Sincronizar Imágenes

**Request:**

```bash
POST /imageUrls/sync
Content-Type: application/json
{
    "updatedSince" : "1990-01-01T00:00:00Z"
}
```

**Response:**

```bash
[
    {
        "createdAt": "2024-08-27T01:10:27Z",
        "id": "0FB79650-D225-425B-80A6-79D65CF3A95D",
        "imageUrl": "http://192.168.2.13:8080/imageUrls/0FB79650-D225-425B-80A6-79D65CF3A95D",
        "updatedAt": "2024-08-27T01:10:27Z",
        "imageHash": "KKLJIIOSADASNFNOIASF"
    },
    {
        "createdAt": "2024-08-27T12:53:18Z",
        "id": "19CE7957-350D-4794-93F2-0273D8EEB165",
        "imageUrl": "https://imagedelivery.net/4fYuQyy-r8_rpBpcY7lH_A/tottusPE/43153812_1/w=1500,h=1500,fit=pad",
        "updatedAt": "2024-08-27T12:53:18Z",
        "imageHash": "HJSJKDFHJAHFSIUNJKFAHIK"
    }
]
```

### Sobre Pull Request al proyecto

* **NO SE ACEPTAN PR** de código sobre el proyecto.

*Esto porque quiero que sea una API que muestre mis habilidades en programación y hacerme cargo de todo un proyecto pequeño en todas sus faces de desarrollo.*

> La idea fundamental es evolucionar la API progresivamente hasta cubrir todas las funcionalidades.

### ¿Cómo puedo contactarte?

## Hola, mi nombre es Angel Curi. Soy el creador de Flor Shop y Flor API Rest.

Soy ingeniero de sistemas desde hace mas de 3 años. Combino mi trabajo como desarrollador RPA y desarrollando Apps en mis tiempos libres y estoy escuchando ofertas sobre Programacíon iOS puedes contactarme desde mi perfil de **[![Web](https://img.shields.io/badge/Linkeding-blue?logo=Linkeding)](https://www.linkedin.com/in/angel-curi-laurente-408b13177/)**.

### En mi perfil de Linkeding tienes más información

[![Web](https://img.shields.io/badge/Linkeding-blue?logo=Linkeding)](https://www.linkedin.com/in/angel-curi-laurente-408b13177/)
