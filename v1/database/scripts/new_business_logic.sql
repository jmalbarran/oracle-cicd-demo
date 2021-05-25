SET ECHO ON

-- CreateTable_Product.sql
ALTER TABLE Product
    ADD (
        -- Modify previously existing business logic (with DDL impact)
        IsActive NUMBER(1,0),
        -- Create a new business logic         
        Price NUMBER(10,2),
        Quantity NUMBER(5,0)
    );

-- Modify previously existing business logic (with no DDL impact)
-- CreateFunction_Greeting.sql
CREATE OR REPLACE FUNCTION Greeting RETURN VARCHAR2 AS
BEGIN
	RETURN 'Hello, from a new brave world!!!';
END;
/

-- Modify previously existing business logic (with DDL impact)
-- CreateFunction_ProductCount.sql
CREATE OR REPLACE FUNCTION ProductCount RETURN NUMBER AS
	l_count NUMBER;
BEGIN
	SELECT COUNT(*) 
	INTO l_count
	FROM Product
    WHERE IsActive=1;

	RETURN l_count;
END;
/


-- Create a new business logic 
-- CreateFunction_ProductCount.sql
CREATE OR REPLACE FUNCTION StockPrice RETURN NUMBER AS
	total NUMBER;
BEGIN
	SELECT SUM(Price*Quantity) 
	INTO total
	FROM Product
    WHERE IsActive=1;

	RETURN total;
END;
/

quit

