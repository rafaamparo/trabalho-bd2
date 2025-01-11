DELIMITER //
DROP procedure IF exists geraCreateTable//
DELIMITER //

CREATE PROCEDURE geraCreateTable(IN schema_name VARCHAR(64))
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE nome_tabela VARCHAR(64);
    DECLARE create_table_sql LONGTEXT DEFAULT '';
    DECLARE cur CURSOR FOR -- cursor para percorrer as tabelas do esquema
        SELECT TABLE_NAME 
        FROM information_schema.TABLES 
        WHERE TABLE_SCHEMA = schema_name;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO nome_tabela;
        IF done THEN
            LEAVE read_loop;
        END IF;

        -- definição das colunas
        SET @columns_sql = NULL;
        SELECT GROUP_CONCAT(
            CONCAT(
                COLUMN_NAME, ' ',
                COLUMN_TYPE, 
                IF(IS_NULLABLE = 'NO', ' NOT NULL', ''),
                IF(COLUMN_DEFAULT IS NOT NULL, CONCAT(' DEFAULT ', QUOTE(COLUMN_DEFAULT)), ''),
                IF(EXTRA != '', CONCAT(' ', EXTRA), '')
            ) ORDER BY ORDINAL_POSITION SEPARATOR ', '
        ) INTO @columns_sql
        FROM information_schema.COLUMNS
        WHERE TABLE_SCHEMA = schema_name AND TABLE_NAME = nome_tabela;

        -- pega chaves primárias
        SET @primary_keys_sql = NULL;
        SELECT GROUP_CONCAT(COLUMN_NAME ORDER BY ORDINAL_POSITION SEPARATOR ', ')
        INTO @primary_keys_sql
        FROM information_schema.KEY_COLUMN_USAGE
        WHERE TABLE_SCHEMA = schema_name 
          AND TABLE_NAME = nome_tabela 
          AND CONSTRAINT_NAME = 'PRIMARY';

        -- pega as FK
        SET @foreign_keys_sql = NULL;
        SELECT GROUP_CONCAT(
            CONCAT(
                'FOREIGN KEY (', COLUMN_NAME, ') REFERENCES ',
                REFERENCED_TABLE_NAME, '(', REFERENCED_COLUMN_NAME, ')'
            ) SEPARATOR ', '
        ) INTO @foreign_keys_sql
        FROM information_schema.KEY_COLUMN_USAGE
        WHERE TABLE_SCHEMA = schema_name 
          AND TABLE_NAME = nome_tabela
          AND REFERENCED_TABLE_NAME IS NOT NULL;

        -- constroi o comando CREATE TABLE
        SET @table_sql = CONCAT(
            'CREATE TABLE ', nome_tabela, ' (',
            @columns_sql,
            IF(@primary_keys_sql IS NOT NULL, CONCAT(', PRIMARY KEY (', @primary_keys_sql, ')'), ''),
            IF(@foreign_keys_sql IS NOT NULL, CONCAT(', ', @foreign_keys_sql), ''),
            ');'
        );
        SET create_table_sql = CONCAT(create_table_sql, @table_sql, '\n\n');
    END LOOP;

    CLOSE cur;
    SELECT create_table_sql AS GeraCreateTable;
END;
//

DELIMITER ;
DROP USER IF EXISTS 'desconto_user'@'localhost';
CREATE USER 'desconto_user'@'localhost' IDENTIFIED BY 'senha';
GRANT EXECUTE ON PROCEDURE geraCreateTable TO 'desconto_user'@'localhost';
CALL geraCreateTable('chinook'); -- caso abra o .csv com os resultados, o resultado do select na barra de fórmulas do Excel aparece formatado