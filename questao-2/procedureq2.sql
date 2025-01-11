use chinook;
DELIMITER //
DROP procedure IF exists removerIndices//
CREATE PROCEDURE removerIndices(IN banco VARCHAR(200), IN tabela VARCHAR(200))

BEGIN
    DECLARE acabou INT DEFAULT 0;
    DECLARE nomeConstraint VARCHAR(255);
    DECLARE tabelaReferenciada VARCHAR(255);
    DECLARE nomeIndice VARCHAR(255); 

   DECLARE cur_referencia CURSOR FOR -- cursor para pegar as tabelas que referenciam a tabela passada
        SELECT TABLE_NAME, CONSTRAINT_NAME
        FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
        WHERE REFERENCED_TABLE_SCHEMA = banco
          AND REFERENCED_TABLE_NAME = tabela;

    DECLARE cur_foreign CURSOR FOR -- cursor para pegar as constraints de foreign key da tabela passada
        SELECT CONSTRAINT_NAME 
        FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
        WHERE TABLE_SCHEMA = banco
          AND TABLE_NAME = tabela
          AND CONSTRAINT_TYPE = 'FOREIGN KEY';

    DECLARE cur_indices CURSOR FOR   -- cursor para pegar os indices da tabela passada
        SELECT INDEX_NAME
        FROM INFORMATION_SCHEMA.STATISTICS
        WHERE TABLE_SCHEMA = banco
          AND TABLE_NAME = tabela;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET acabou = 1;
    OPEN cur_referencia;

    referencia_loop: LOOP -- loop para remover as constraints de foreign key das tabelas que referenciam a tabela passada
        FETCH cur_referencia INTO tabelaReferenciada, nomeConstraint;
        IF acabou THEN
            LEAVE referencia_loop;
        END IF;
        SET @dropFKStmt = CONCAT('ALTER TABLE ', tabelaReferenciada, ' DROP FOREIGN KEY ', nomeConstraint);
        PREPARE stmt FROM @dropFKStmt;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END LOOP;

    CLOSE cur_referencia;
    SET acabou = 0;
    OPEN cur_foreign;

    read_foreign: LOOP -- loop para remover as constraints de foreign key da tabela passada
        FETCH cur_foreign INTO nomeConstraint;
        IF acabou THEN
            LEAVE read_foreign;
        END IF;
        SET @dropFKStmt = CONCAT('ALTER TABLE ', tabela, ' DROP FOREIGN KEY ', nomeConstraint);
        PREPARE stmt FROM @dropFKStmt;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END LOOP;

    CLOSE cur_foreign;

    SET acabou = 0; 
    OPEN cur_indices;

    read_indices: LOOP -- loop para remover os indices da tabela passada
        FETCH cur_indices INTO nomeIndice;
        IF acabou THEN
            LEAVE read_indices;
        END IF;

        IF nomeIndice = 'PRIMARY' THEN
            SET @dropIndexStmt = CONCAT('ALTER TABLE ', tabela, ' DROP PRIMARY KEY');
        ELSE
            SET @dropIndexStmt = CONCAT('ALTER TABLE ', tabela, ' DROP INDEX ', nomeIndice);
        END IF;

        PREPARE stmt FROM @dropIndexStmt;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END LOOP;

    CLOSE cur_indices;
END //

DELIMITER ;

CALL removerIndices("chinook", "album")
DROP USER IF EXISTS 'desconto_user'@'localhost';
CREATE USER 'desconto_user'@'localhost' IDENTIFIED BY 'senha';
GRANT EXECUTE ON PROCEDURE removerIndices TO 'desconto_user'@'localhost';