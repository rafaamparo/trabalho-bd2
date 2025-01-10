use chinook;
DROP TRIGGER IF Exists new_track_price;
DROP TRIGGER IF Exists update_track_price;

-- Regra 1 -- O valor de uma track cadastrada não pode ser menor que 0,05

DELIMITER $$
CREATE TRIGGER new_track_price
BEFORE INSERT ON track
FOR EACH ROW
BEGIN
    IF new.unitPrice < 0.05 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'O preço da track cadastrada é muito barato! O valor deve ser maior que 0,05s';
    END IF;
END $$

DELIMITER $$
CREATE TRIGGER update_track_price
BEFORE UPDATE ON track
FOR EACH ROW
BEGIN
    IF new.unitPrice < 0.05 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'O preço da track cadastrada é muito barato! O valor deve ser maior que 0,05s';
    END IF;
END $$

DELIMITER ;

-- testes
INSERT INTO Track VALUES (4569987, "Sara's Smile", 4569989, 3, 8, "Taylor Swift", 232323, 8, 0.03);
INSERT INTO Track VALUES (4569987, "Sara's Smile", 4569989, 3, 8, "Taylor Swift", 232323, 8, 0.33);
UPDATE Track SET unitPrice = 0.03 WHERE TrackId = 4569987