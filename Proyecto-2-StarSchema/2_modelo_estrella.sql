/* 
  PROYECTO 2: Modelado de Data Warehouse (Star Schema) y SCD Tipo 2
  MOTOR: PostgreSQL
  OBJETIVO: Transformar datos operativos en un modelo optimizado para analítica histórica.

  DESCRIPCIÓN:
  Este proyecto simula la migración de datos de un sistema transaccional (OLTP) a un 
  modelo analítico (OLAP). Se implementa una Dimensión de Cambio Lento (SCD) Tipo 2
  para rastrear el historial de los clientes.
*/

-- 1. CREACIÓN DE ESQUEMA
CREATE SCHEMA IF NOT EXISTS dw_store;

-- 2. DIMENSIÓN CLIENTES (SCD Tipo 2)
-- Esta tabla permite rastrear cambios históricos en los atributos de los clientes.
CREATE TABLE IF NOT EXISTS dw_store.dim_clientes (
    cliente_sk SERIAL PRIMARY KEY,      -- Surrogate Key (Llave subrogada para el DW)
    user_id INT NOT NULL,               -- Natural Key (ID del sistema fuente)
    nombre VARCHAR(100),
    ciudad VARCHAR(100),
    email VARCHAR(100),
    version_actual BOOLEAN DEFAULT TRUE,
    fecha_inicio TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_fin TIMESTAMP                 -- NULL indica que es la versión activa
);

-- 3. TABLA DE HECHOS: VENTAS
-- Nota: La tabla de hechos se conecta a la Surrogate Key (cliente_sk), 
-- garantizando la integridad referencial histórica.
CREATE TABLE IF NOT EXISTS dw_store.fact_ventas (
    venta_id SERIAL PRIMARY KEY,
    cliente_sk INT REFERENCES dw_store.dim_clientes(cliente_sk),
    fecha_venta DATE DEFAULT CURRENT_DATE,
    monto_total DECIMAL(12,2),
    cantidad_items INT
);

-- 4. LÓGICA DE CARGA (ETL SIMULADO)
-- En un entorno real, este proceso sería parte de un pipeline de Airflow o dbt.

/* 
   CASO DE USO: 
   El usuario 101 se muda de 'CDMX' a 'Monterrey'.
   El sistema debe "cerrar" la versión de CDMX y "abrir" la de Monterrey.
*/

-- Paso A: Desactivar versión actual si hay cambios detectados
UPDATE dw_store.dim_clientes
SET version_actual = FALSE,
    fecha_fin = CURRENT_TIMESTAMP
WHERE user_id = 101 
  AND version_actual = TRUE 
  AND ciudad <> 'Monterrey';

-- Paso B: Insertar nueva versión
INSERT INTO dw_store.dim_clientes (user_id, nombre, ciudad, email)
SELECT 101, 'Juan Perez', 'Monterrey', 'juan.p@email.com'
WHERE NOT EXISTS (
    SELECT 1 FROM dw_store.dim_clientes 
    WHERE user_id = 101 AND version_actual = TRUE
);

-- 5. POBLACIÓN DE DATOS PARA PRUEBA DE ANALÍTICA
INSERT INTO dw_store.fact_ventas (cliente_sk, monto_total, cantidad_items)
SELECT cliente_sk, 1500.50, 2 FROM dw_store.dim_clientes WHERE user_id = 101;

-- 6. CONSULTA DE VALOR DE NEGOCIO
-- Esta consulta demuestra la potencia del modelo: podemos ver las ventas 
-- desglosadas por la ubicación del cliente en el momento de la compra.
SELECT 
    c.nombre,
    c.ciudad,
    COUNT(f.venta_id) as total_ordenes,
    SUM(f.monto_total) as ingresos_totales
FROM dw_store.fact_ventas f
JOIN dw_store.dim_clientes c ON f.cliente_sk = c.cliente_sk
GROUP BY c.nombre, c.ciudad;
