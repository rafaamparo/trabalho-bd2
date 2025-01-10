-- Regra 2: Customers só podem ser atendidos por employees do mesmo estado

use chinook;
DROP TRIGGER IF Exists new_employee_customer;
DROP TRIGGER IF Exists update_employee_customer;

DELIMITER $$
CREATE TRIGGER new_employee_customer
BEFORE INSERT ON customer
FOR EACH ROW
BEGIN
DECLARE state_employee VARCHAR(50);
    SELECT state INTO state_employee FROM employee WHERE EmployeeId = NEW.SupportRepId;
    IF new.State <> state_employee THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'O customer só pode ser atendido por um Employee do mesmo estado.';
    END IF;
END $$

DELIMITER $$
CREATE TRIGGER update_employee_customer
BEFORE UPDATE ON customer
FOR EACH ROW
BEGIN
DECLARE state_employee VARCHAR(50);
    SELECT state INTO state_employee FROM employee WHERE EmployeeId = NEW.SupportRepId;
    IF new.State <> state_employee THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'O customer só pode ser atendido por um Employee do mesmo estado.';
    END IF;
END $$
DELIMITER ;

-- testes
INSERT INTO Employee (EmployeeId, LastName, FirstName, Title, ReportsTo, State) VALUES (11568, 'Cavalcante', 'Mara', 'IT Staff', 1, 'SP');
INSERT INTO customer (CustomerId, FirstName, LastName, State, Email, SupportRepId) VALUES (68998, 'Erick', 'Rebello', 'BA','erikito@gmail.com', 11568);
INSERT INTO customer (CustomerId, FirstName, LastName, State, Email, SupportRepId) VALUES (68998, 'Erick', 'Rebello', 'SP','erikito@gmail.com', 11568);
UPDATE customer SET State = 'BA' WHERE CustomerID = 68998