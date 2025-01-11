use chinook;
DROP TRIGGER IF Exists update_invoice_total_apos_insert;
DROP TRIGGER IF Exists update_invoice_total_apos_update;
DROP TRIGGER IF Exists update_invoice_total_apos_delete;

DELIMITER //

CREATE TRIGGER update_invoice_total_apos_insert
AFTER INSERT ON InvoiceLine
FOR EACH ROW
BEGIN
    UPDATE Invoice
    SET Total = (
        SELECT SUM(UnitPrice * Quantity)
        FROM InvoiceLine
        WHERE InvoiceId = NEW.InvoiceId
    )
    WHERE InvoiceId = NEW.InvoiceId;
END;
//

CREATE TRIGGER update_invoice_total_apos_update
AFTER UPDATE ON InvoiceLine
FOR EACH ROW
BEGIN
    UPDATE Invoice
    SET Total = (
        SELECT SUM(UnitPrice * Quantity)
        FROM InvoiceLine
        WHERE InvoiceId = NEW.InvoiceId
    )
    WHERE InvoiceId = NEW.InvoiceId;
END;
//

CREATE TRIGGER update_invoice_total_apos_delete
AFTER DELETE ON InvoiceLine
FOR EACH ROW
BEGIN
    UPDATE Invoice
    SET Total = (
        SELECT COALESCE(SUM(UnitPrice * Quantity), 0)
        FROM InvoiceLine
        WHERE InvoiceId = OLD.InvoiceId
    )
    WHERE InvoiceId = OLD.InvoiceId;
END;
//

DELIMITER ;

-- teste para create
INSERT INTO InvoiceLine (InvoiceLineId, InvoiceId, TrackId, UnitPrice, Quantity) VALUES (109887, 1, 1, 9.99, 2);
SELECT * FROM InvoiceLine WHERE InvoiceId = 1;
SELECT Total FROM Invoice WHERE InvoiceId = 1;

-- teste para update
UPDATE InvoiceLine SET Quantity = 3 WHERE InvoiceLineId = 1; 
SELECT * FROM InvoiceLine WHERE InvoiceId = 1;
SELECT Total FROM Invoice WHERE InvoiceId = 1;

-- teste para delete 
DELETE FROM InvoiceLine WHERE InvoiceLineId = 109887;
SELECT * FROM InvoiceLine WHERE InvoiceId = 1;
SELECT Total FROM Invoice WHERE InvoiceId = 1;


