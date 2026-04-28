/* PASO FINAL: Generación de la Matriz de Retención (Pivot)
   Esto convierte los 'month_number' en columnas para facilitar la lectura.
*/

WITH retention_base AS (
    -- Reutilizamos la logica exacta
    SELECT 
        cohort_month,
        DATE_DIFF(DATE_TRUNC(DATE(created_at), MONTH), cohort_month, MONTH) AS month_number,
        COUNT(DISTINCT user_id) AS active_users
    FROM (
        SELECT user_id, created_at,
               DATE_TRUNC(MIN(DATE(created_at)) OVER(PARTITION BY user_id), MONTH) AS cohort_month
        FROM `bigquery-public-data.thelook_ecommerce.orders`
        WHERE status NOT IN ('Cancelled', 'Returned')
    )
    GROUP BY 1, 2
)

SELECT * FROM (
    -- Seleccionamos solo las cohortes más recientes para que la tabla sea legible
    SELECT 
        cohort_month,
        month_number,
        active_users
    FROM retention_base
    WHERE cohort_month >= '2023-01-01' 
)
PIVOT (
    SUM(active_users) 
    FOR month_number IN (0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12)
)
ORDER BY cohort_month DESC;
