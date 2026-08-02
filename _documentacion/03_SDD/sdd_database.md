# SDD - Database
# Especificación Driven Design basada en ingeniería reversa de `/mnt/pruebamotorsocial/lib/core/database` y `/mnt/pruebamotorsocial/lib/motorsocial/core/database`

## 1. Requerimientos Ubicuarios

1. El sistema deberá exponer un repositorio genérico de CouchDB con operaciones CRUD básicas.
2. El sistema deberá soportar configuración de esquema, host, puerto, usuario y contraseña.
3. El sistema deberá construir URIs absolutas para cada operación HTTP.
4. El sistema deberá permitir implementaciones en memoria como fallback.

## 2. Requerimientos Controlados por Eventos

1. Cuando se invoque `ping()`, el sistema deberá ejecutar un `GET` a la raíz de CouchDB y retornar `true` si el estado es 200.
2. Cuando se invoque `createDatabase(db)`, el sistema deberá ejecutar un `PUT` al path de la base y considerar éxito si retorna 201 o 412.
3. Cuando se invoque `ensureDatabase(db)`, el sistema deberá verificar conectividad y crear la base si no existe.
4. Cuando se invoque `put(db, doc)`, el sistema deberá serializar el documento como JSON y enviarlo a CouchDB.
5. Cuando se invoque `queryView(db, design, view)`, el sistema deberá consultar la vista de diseño especificada.

## 3. Requerimientos Controlados por Estados

1. Mientras el cliente HTTP esté vivo, el sistema deberá reutilizar la misma instancia para todas las operaciones.
2. Mientras la autenticación básica esté configurada, el sistema deberá incluir el header `Authorization` en cada request.

## 4. Requerimientos de Comportamiento No Deseado

1. Si la respuesta HTTP no es exitosa, entonces el sistema deberá lanzar una excepción con el status y cuerpo de CouchDB.
2. Si no se proporciona cliente HTTP, entonces el sistema deberá crear un `http.Client()` interno.
3. Si la base de datos ya existe, entonces el sistema deberá considerar la operación exitosa.

## 5. Requerimientos de Funciones Opcionales

1. Donde el sistema incluya `DatabaseModule.local()`, el sistema deberá retornar una instancia conectada a `citigov.cloud:6984`.
2. Donde el sistema incluya repositorios específicos, el sistema deberá extender `CouchDbRepository` para dominios como usuarios, grupos, medios, etc.
3. Donde el sistema incluya `in_memory_repository_impls.dart`, el sistema deberá ofrecer implementaciones sin red para testing.
