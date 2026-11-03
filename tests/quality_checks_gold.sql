/*
===============================================================================
Quality Checks
===============================================================================
Script Purpose:
    This script performs quality checks to validate the integrity, consistency,
    and accuracy of the Gold Layer. These checks ensure:
    - Uniqueness of surrogate keys in dimension tables.
    - Referential integrity between fact and dimension tables.
    - Validation of relationships in the data model for analytical purposes.

Usage Notes:
    - Run these checks after data loading Silver Layer.
    - Investigate and resolve any discrepancies found during the checks.
===============================================================================
*/
USE [DataWarehouse];
GO

-- Expect no rows: one record per customer ID and current product number.
SELECT customer_id, COUNT(*) AS row_count
FROM gold.dim_customers
GROUP BY customer_id
HAVING customer_id IS NULL OR COUNT(*) > 1;

SELECT product_number, COUNT(*) AS row_count
FROM gold.dim_products
GROUP BY product_number
HAVING product_number IS NULL OR COUNT(*) > 1;

-- Expect no rows: sales without a matching dimension record.
SELECT f.*
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_customers AS c ON c.customer_key = f.customer_key
LEFT JOIN gold.dim_products AS p ON p.product_key = f.product_key
WHERE c.customer_key IS NULL OR p.product_key IS NULL;

-- Compare the source and resulting sales row counts.
SELECT
    (SELECT COUNT_BIG(*) FROM silver.crm_sales_details) AS silver_sales_rows,
    (SELECT COUNT_BIG(*) FROM gold.fact_sales) AS gold_sales_rows;
