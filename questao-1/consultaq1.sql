use chinook;

SELECT 
    TABLE_NAME AS tabela,
    INDEX_NAME AS indice,
    COLUMN_NAME AS coluna
FROM 
    information_schema.STATISTICS
WHERE 
    TABLE_SCHEMA = 'Chinook'
ORDER BY 
    TABLE_NAME, INDEX_NAME;