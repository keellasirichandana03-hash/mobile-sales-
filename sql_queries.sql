-- View All Record
SELECT * FROM mobile_sales_raw;

-- Count Total Records
SELECT COUNT(*) AS total_records
FROM mobile_sales_raw;


-- Find NULL Values
SELECT *
FROM mobile_sales_raw
WHERE sale_id IS NULL
   OR mobile_model IS NULL
   OR brand IS NULL
   OR price IS NULL
   OR quantity IS NULL
   OR sale_date IS NULL
   OR customer_name IS NULL
   OR payment_method IS NULL
   OR city IS NULL
   OR rating IS NULL;


-- Find Duplicate sale_id
SELECT sale_id,
       COUNT(*) AS duplicate_count
FROM mobile_sales_raw
GROUP BY sale_id
HAVING COUNT(*) > 1;


-- Find Invalid Prices
-- Non-numeric prices
SELECT *
FROM mobile_sales_raw
WHERE price NOT REGEXP '^[0-9]+$';

-- Negative prices
SELECT *
FROM mobile_sales_raw
WHERE CAST(price AS SIGNED) < 0;


-- Find Invalid Quantity
SELECT *
FROM mobile_sales_raw
WHERE quantity IS NULL
   OR quantity NOT REGEXP '^[0-9]+$'
   OR CAST(quantity AS SIGNED) <= 0;


-- Find Invalid Ratings
SELECT *
FROM mobile_sales_raw
WHERE rating NOT REGEXP '^[0-9]+$'
   OR CAST(rating AS SIGNED) NOT BETWEEN 1 AND 5;


-- Find Invalid Customer Names
SELECT *
FROM mobile_sales_raw
WHERE customer_name REGEXP '[0-9@#!$%^&*()]'
   OR customer_name IN ('Test', 'Dummy', 'Unknown', '???');


-- Check Brand Inconsistency
SELECT DISTINCT brand
FROM mobile_sales_raw;


-- Check City Inconsistency
SELECT DISTINCT city
FROM mobile_sales_raw;


-- Check Payment Method Inconsistency
SELECT DISTINCT payment_method
FROM mobile_sales_raw;


-- Create Clean Table
CREATE TABLE clean_mobile_sales (
    sale_id INT PRIMARY KEY,
    mobile_model VARCHAR(100),
    brand VARCHAR(50),
    price DECIMAL(10,2),
    quantity INT,
    sale_date DATE,
    customer_name VARCHAR(100),
    payment_method VARCHAR(20),
    city VARCHAR(50),
    rating INT
);


-- Insert Cleaned Data
INSERT INTO clean_mobile_sales

SELECT DISTINCT

    CAST(sale_id AS UNSIGNED) AS sale_id,

    TRIM(mobile_model) AS mobile_model,

    CASE
        WHEN LOWER(brand) = 'apple' THEN 'Apple'
        WHEN LOWER(brand) = 'samsung' THEN 'Samsung'
        WHEN LOWER(brand) = 'xiaomi' THEN 'Xiaomi'
        WHEN LOWER(brand) = 'vivo' THEN 'Vivo'
        WHEN LOWER(brand) = 'oneplus' THEN 'OnePlus'
        WHEN LOWER(brand) = 'realme' THEN 'Realme'
        ELSE brand
    END AS brand,

    CAST(price AS DECIMAL(10,2)) AS price,

    CAST(quantity AS UNSIGNED) AS quantity,

    CASE
        WHEN sale_date REGEXP '^[0-9]{2}-[0-9]{2}-[0-9]{4}$'
        THEN STR_TO_DATE(sale_date,'%d-%m-%Y')

        WHEN sale_date REGEXP '^[0-9]{2}-[A-Za-z]{3}-[0-9]{2}$'
        THEN STR_TO_DATE(sale_date,'%d-%b-%y')

        ELSE NULL
    END AS sale_date,

    REGEXP_REPLACE(
        TRIM(customer_name),
        '[^a-zA-Z ]',
        ''
    ) AS customer_name,

    CASE
        WHEN LOWER(payment_method) = 'upi' THEN 'UPI'
        WHEN LOWER(payment_method) = 'cash' THEN 'Cash'
        WHEN LOWER(payment_method) = 'card' THEN 'Card'
        ELSE 'Unknown'
    END AS payment_method,

    CASE
        WHEN LOWER(city) IN ('hyd','hyderabad')
        THEN 'Hyderabad'

        WHEN LOWER(city) IN ('blr','bangalore')
        THEN 'Bangalore'

        WHEN LOWER(city) = 'mumbai'
        THEN 'Mumbai'

        WHEN LOWER(city) = 'delhi'
        THEN 'Delhi'

        WHEN LOWER(city) = 'chennai'
        THEN 'Chennai'

        ELSE city
    END AS city,

    CAST(rating AS UNSIGNED) AS rating

FROM mobile_sales_raw

WHERE

    sale_id IS NOT NULL

    AND mobile_model IS NOT NULL
    AND mobile_model <> ''

    AND brand IS NOT NULL
    AND brand <> ''

    AND customer_name IS NOT NULL
    AND customer_name NOT IN
    ('Test','Dummy','Unknown','???','TestUser')

    AND price REGEXP '^[0-9]+$'
    AND CAST(price AS SIGNED) > 0

    AND quantity REGEXP '^[0-9]+$'
    AND CAST(quantity AS SIGNED) > 0

    AND rating REGEXP '^[0-9]+$'
    AND CAST(rating AS SIGNED) BETWEEN 1 AND 5;


-- View Cleaned Data
SELECT * FROM clean_mobile_sales;


-- Validation Queries
-- Count Before Cleaning
SELECT COUNT(*) AS raw_records
FROM mobile_sales_raw;


-- Count After Cleaning
SELECT COUNT(*) AS cleaned_records
FROM clean_mobile_sales;


-- Check Duplicates in Clean Table
SELECT sale_id,
COUNT(*)
FROM clean_mobile_sales
GROUP BY sale_id
HAVING COUNT(*) > 1;


-- Check NULL Values
SELECT *
FROM clean_mobile_sales
WHERE sale_id IS NULL
   OR mobile_model IS NULL
   OR brand IS NULL
   OR price IS NULL
   OR quantity IS NULL
   OR sale_date IS NULL;


-- Sales Analysis Queries
-- Total Sales By Brand
SELECT brand,
       SUM(price * quantity) AS total_sales
FROM clean_mobile_sales
GROUP BY brand
ORDER BY total_sales DESC;



SELECT city,
       SUM(quantity) AS total_quantity
FROM clean_mobile_sales
GROUP BY city
ORDER BY total_quantity DESC;



SELECT brand,
       AVG(rating) AS avg_rating
FROM clean_mobile_sales
GROUP BY brand;



SELECT * FROM clean_mobile_sales
