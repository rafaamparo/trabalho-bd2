-- Regra 3: Em dezembro, deve ser aplicado um desconto de 25% nas compras de todo customer que for também funcionário da loja

use chinook;
DELIMITER //
DROP procedure IF exists descontoDeNatal//
DELIMITER //

CREATE PROCEDURE descontoDeNatal(
    IN invoice_id INT,
    IN customer_id INT,
    IN invoice_date DATETIME,
    IN billing_address NVARCHAR(70),
    IN billing_city NVARCHAR(40),
    IN billing_state NVARCHAR(40),
    IN billing_country NVARCHAR(10),
    IN billing_postal_code NVARCHAR(10),
    IN total NUMERIC(10,2))
BEGIN
	DECLARE novoTotal NUMERIC(10,2) default total;
    IF MONTH(invoice_date) = 12 THEN -- checa se o mês é dezembro
		IF customer_id IN (SELECT c.customerId 
				FROM customer c 
				INNER JOIN employee e -- verifica se o customer é employee comparando o primeiro e segundo nome
				ON (c.LastName = e.LastName) AND 
				(c.FirstName = e.FirstName)
				WHERE c.customerId = customer_id) THEN
			SET novoTotal = 0.75*total; -- aplica o desconto
            END IF;
    END IF;
    INSERT INTO invoice (
		InvoiceId,
        CustomerId,
        InvoiceDate,
        BillingAddress,
        BillingCity,
        BillingState,
        BillingCountry,
        BillingPostalCode,
        Total
    ) VALUES (
		invoice_id,
        customer_id,
        invoice_date,
        billing_address,
        billing_city,
        billing_state,
        billing_country,
        billing_postal_code,
        novoTotal
    );
END;
//

DELIMITER ;

-- cria um usuário que tem permissão a procedure e revoga permissões anteriores que possam existir
DROP USER IF EXISTS 'desconto_user'@'localhost';
CREATE USER 'desconto_user'@'localhost' IDENTIFIED BY 'senha';
GRANT EXECUTE ON PROCEDURE descontoDeNatal TO 'desconto_user'@'localhost';

-- testes
INSERT INTO Employee (EmployeeId, LastName, FirstName, Title, ReportsTo, State) VALUES (11568, 'Cavalcante', 'Mara', 'IT Staff', 1, 'SP');
INSERT INTO customer (CustomerId, FirstName, LastName, State, Email, SupportRepId) VALUES (68998, 'Mara', 'Cavalcante', 'SP','erikito@gmail.com', 1);
CALL descontoDeNatal(11111, 68998,'2025-12-15', 'avenida do contorno', 'Niteroi', 'RJ', 'BR', '10001', 100.00);
SELECT * FROM invoice WHERE InvoiceId = 11111;
