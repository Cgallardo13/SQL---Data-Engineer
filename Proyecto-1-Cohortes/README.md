# Análisis de Retención por Cohortes - Dataset TheLook eCommerce

Este proyecto implementa un análisis de cohortes para medir la retención de usuarios a lo largo del tiempo. El objetivo es identificar el comportamiento de recompra de los clientes basándose en su mes de adquisición.

## Contexto y Valor de Negocio
La retención de usuarios es una métrica crítica para cualquier plataforma de comercio electrónico. Este análisis permite segmentar a los usuarios por su fecha de registro (cohorte) y observar cuántos meses permanecen activos realizando transacciones. Esta información es fundamental para evaluar la salud del negocio y la efectividad de las estrategias de fidelización.

## Stack Técnico
- **Entorno:** Google BigQuery (Cloud Data Warehouse).
- **Lenguaje:** Standard SQL.
- **Dataset:** `bigquery-public-data.thelook_ecommerce`.

## Implementación Técnica y Decisiones de Diseño

La solución se estructuró mediante Expresiones de Tabla Comunes (CTEs) para garantizar la legibilidad y el mantenimiento del código, siguiendo las mejores prácticas de ingeniería de datos.

### 1. Detección de la Primera Compra
Se utilizó la función de ventana `MIN() OVER(PARTITION BY user_id)` para identificar la fecha exacta de adquisición de cada usuario. Esta técnica es superior a un `GROUP BY` tradicional ya que permite conservar el detalle de todas las transacciones individuales mientras se asocia la métrica de origen a cada fila.

### 2. Normalización Temporal
Se aplicó `DATE_TRUNC` para agrupar las fechas por mes, permitiendo la creación de cohortes uniformes. La diferencia de meses entre la compra actual y la inicial se calculó mediante `DATE_DIFF`.

### 3. Optimización con Window Functions
Para el cálculo de la tasa de retención, se empleó `FIRST_VALUE() OVER(PARTITION BY cohort_month ORDER BY month_number)`. Esto permite acceder al tamaño total de la cohorte (Mes 0) desde cualquier fila subsiguiente sin recurrir a un `Self-Join`, lo cual optimiza significativamente el tiempo de ejecución en BigQuery al procesar grandes volúmenes de datos.

### 4. Integridad de los Datos
Se implementó `SAFE_DIVIDE` para prevenir errores de ejecución por división entre cero y se filtraron estados de orden no exitosos (Cancelled, Returned) para asegurar que el análisis se base únicamente en ingresos reales.

## Estructura de Salida
La consulta final entrega:
- **cohort_month:** Mes de adquisición del usuario.
- **month_number:** Meses transcurridos desde la primera compra.
- **active_users:** Cantidad de usuarios únicos activos en ese periodo.
- **total_users:** Tamaño original de la cohorte.
- **retention_rate:** Porcentaje de retención calculado.

---
*Este proyecto demuestra dominio de SQL avanzado, optimización de consultas en la nube y capacidad de transformar datos transaccionales en insights de negocio.*
