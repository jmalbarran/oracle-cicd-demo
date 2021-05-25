SET ECHO ON

-- CreateTable_Product.sql
CREATE TABLE Product(
	Id NUMBER,
	Name VARCHAR2(50),
	CONSTRAINT PK_Product PRIMARY KEY (Id)
);

DECLARE
  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN

    ORDS.ENABLE_OBJECT(p_enabled => TRUE,
                       p_schema => 'DEMO_DEV',
                       p_object => 'PRODUCT',
                       p_object_type => 'TABLE',
                       p_object_alias => 'product',
                       p_auto_rest_auth => FALSE);

    commit;

END;
/

CREATE SEQUENCE Product_Seq
START WITH 1
MAXVALUE 999999999999999999999999999
MINVALUE 1
NOCYCLE
CACHE 20
NOORDER;

-- CreateFunction_ProductCount.sql
CREATE OR REPLACE FUNCTION ProductCount RETURN NUMBER AS
	l_count NUMBER;
BEGIN
	SELECT COUNT(*) 
	INTO l_count
	FROM Product;

	RETURN l_count;
END;
/


-- CreateFunction_Greeting.sql
CREATE OR REPLACE FUNCTION Greeting RETURN VARCHAR2 AS
BEGIN
	RETURN 'Hello, world!!!';
END;
/




quit

