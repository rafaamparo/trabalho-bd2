use chinook;
SELECT 
    rc.CONSTRAINT_NAME AS foreign_key,
    rc.TABLE_NAME AS tabela,
    kcu.COLUMN_NAME AS coluna,
    rc.REFERENCED_TABLE_NAME AS tabela_referenciada,
    kcu.REFERENCED_COLUMN_NAME AS coluna_referenciada
FROM 
    information_schema.REFERENTIAL_CONSTRAINTS rc
JOIN 
    information_schema.KEY_COLUMN_USAGE kcu
ON 
    rc.CONSTRAINT_NAME = kcu.CONSTRAINT_NAME
    AND rc.TABLE_NAME = kcu.TABLE_NAME
    AND rc.CONSTRAINT_SCHEMA = kcu.TABLE_SCHEMA
WHERE 
    rc.CONSTRAINT_SCHEMA = 'Chinook'
ORDER BY 
    rc.TABLE_NAME, rc.CONSTRAINT_NAME;
