CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    quantity INT NOT NULL DEFAULT 0
);

CREATE TABLE operations_log (
    id SERIAL PRIMARY KEY,
    product_id INT REFERENCES products(id),
    operation VARCHAR(10) CHECK (operation IN ('ADD', 'REMOVE')),
    quantity INT NOT NULL
);

INSERT INTO products(id, name, quantity)
VALUES(1, 'Tomato', 5);

CREATE OR REPLACE PROCEDURE update_stock(product_id INT, operation VARCHAR, quantit INT)
LANGUAGE plpgsql AS $$
BEGIN
    IF operation = 'ADD' THEN
        UPDATE products
        SET quantity = products.quantity + quantit
        WHERE id = product_id;

        INSERT INTO operations_log (product_id, operation, quantity)
        VALUES (product_id, operation, quantit);

    ELSIF operation = 'REMOVE' THEN

        IF (SELECT products.quantity FROM products WHERE id = product_id) >= quantit THEN

            UPDATE products
            SET quantity = products.quantity - quantit
            WHERE id = product_id;

            INSERT INTO operations_log (product_id, operation, quantity)
            VALUES (product_id, operation, quantit);
        ELSE
            RAISE EXCEPTION 'Ошибка: количество списываемого товара больше, чем есть на складе';
        END IF;

    ELSE
        RAISE EXCEPTION 'Триггер: %', operation;
    END IF;
END;
$$;

CALL update_stock(1, 'REMOVE', 10);
CALL update_stock(1, 'ADD', 10);

SELECT * FROM products;
SELECT * FROM operations_log;