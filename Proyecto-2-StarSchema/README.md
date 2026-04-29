# Modelado de Data Warehouse: Star Schema y SCD Tipo 2

Este proyecto demuestra la capacidad de diseñar y construir un almacén de datos (Data Warehouse) utilizando un modelo de estrella y gestionando cambios históricos mediante Dimensiones de Cambio Lento (SCD) Tipo 2.

## Objetivo del Proyecto
Transformar datos de un entorno transaccional (OLTP) a un modelo optimizado para analítica (OLAP). El foco principal es garantizar la integridad histórica de los datos, permitiendo que los reportes reflejen la realidad del negocio en el momento en que ocurrieron los eventos, independientemente de los cambios posteriores en los atributos de las entidades.

## Stack Técnico
- **Motor:** PostgreSQL.
- **Lenguaje:** SQL Procedural (PL/pgSQL).
- **Modelo de Datos:** Star Schema (Hechos y Dimensiones).

## Conceptos Avanzados Implementados

### 1. Dimensiones de Cambio Lento (SCD) Tipo 2
Se implementó una lógica que permite rastrear el historial de los clientes. En lugar de sobreescribir la información cuando un cliente cambia un atributo (como su ciudad), el sistema:
- "Cierra" la versión actual marcándola con una fecha de fin.
- "Abre" una nueva versión con los datos actualizados.
Esto es vital para la precisión de los reportes históricos.

### 2. Llaves Subrogadas (Surrogate Keys)
Se utilizaron llaves primarias artificiales (`cliente_sk`) generadas mediante `SERIAL`. Esto desacopla el Data Warehouse de los IDs de los sistemas fuente y es la mejor práctica para manejar múltiples versiones de un mismo registro natural.

### 3. Integridad Referencial en el Star Schema
La Tabla de Hechos (`fact_ventas`) se relaciona directamente con las llaves subrogadas de las dimensiones, asegurando que cada venta esté vinculada a la "foto" exacta del cliente al momento de la transacción.

## Estructura del Modelo
- **dw_store.dim_clientes:** Contiene atributos de clientes con campos de auditoría (`version_actual`, `fecha_inicio`, `fecha_fin`).
- **dw_store.fact_ventas:** Almacena las métricas de negocio (monto, cantidad) y las llaves foráneas hacia las dimensiones.

## Impacto en el Negocio
Con esta estructura, el departamento de analítica puede realizar consultas de "viaje en el tiempo". Por ejemplo, si un cliente realizó compras viviendo en CDMX y luego se mudó a Monterrey, el modelo permite atribuir correctamente los ingresos a cada ciudad según la fecha de la compra, evitando la corrupción de datos históricos.

---
*Este proyecto refleja un dominio profundo de arquitectura de datos y preparación de entornos para Business Intelligence.*
