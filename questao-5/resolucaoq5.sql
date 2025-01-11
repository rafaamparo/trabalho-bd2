DROP TABLE IF Exists transicao;
DROP TABLE IF Exists entidade;
DROP TABLE IF Exists estado;

CREATE TABLE estado (
    nome VARCHAR(50) PRIMARY KEY
);
CREATE TABLE transicao (
    estado_previo VARCHAR(50) NOT NULL,
    proximo_estado VARCHAR(50) NOT NULL,
    PRIMARY KEY (estado_previo, proximo_estado),
    FOREIGN KEY (estado_previo) REFERENCES estado(nome),
    FOREIGN KEY (proximo_estado) REFERENCES estado(nome)
);
CREATE TABLE entidade (
    id INT AUTO_INCREMENT PRIMARY KEY,
    state VARCHAR(50) NOT NULL,
    FOREIGN KEY (state) REFERENCES estado(nome)
);
DROP TRIGGER IF Exists valida_transicao

DELIMITER //

CREATE TRIGGER valida_transicao
BEFORE UPDATE ON entidade
FOR EACH ROW
BEGIN
    -- verifica validade da transicao
    IF NOT EXISTS (
        SELECT 1 
        FROM transicao 
        WHERE estado_previo = OLD.state AND proximo_estado = NEW.state
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Transição de estado inválida!';
    END IF;
END;
//

DELIMITER ;

INSERT INTO estado (nome) VALUES 
('A'), ('B'), ('C'), ('D');

INSERT INTO transicao (estado_previo, proximo_estado) VALUES 
('A', 'B'),
('B', 'C'),
('C', 'D'),
('D', 'A'); 

INSERT INTO entidade (state) VALUES ('A');

UPDATE entidade SET state = 'B' WHERE id = 1; -- transição valida A -> B
UPDATE entidade SET state = 'D' WHERE id = 1; -- transição invalida B -> D
UPDATE entidade SET state = 'C' WHERE id = 1; -- transição valida B -> D