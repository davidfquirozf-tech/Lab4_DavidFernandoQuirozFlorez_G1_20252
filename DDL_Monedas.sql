CREATE TABLE Moneda (
    idmoneda SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    codigo VARCHAR(3) NOT NULL UNIQUE
);

CREATE TABLE CambioMoneda (
    idcambio SERIAL PRIMARY KEY,
    idmoneda INT NOT NULL,
    fecha DATE NOT NULL,
    valor DOUBLE PRECISION NOT NULL,
    FOREIGN KEY (idmoneda) REFERENCES Moneda(idmoneda),
    UNIQUE(idmoneda, fecha)
);
DO $$
DECLARE
    monedas TEXT[] := ARRAY['USD','EUR','GBP','JPY'];
    moneda_actual TEXT;
    fecha_actual DATE := (CURRENT_DATE - INTERVAL '2 months')::date;
    fecha_fin DATE := CURRENT_DATE;
    valor_random NUMERIC;
    idMon INT;
BEGIN
    FOREACH moneda_actual IN ARRAY monedas LOOP

        SELECT idmoneda INTO idMon 
        FROM Moneda 
        WHERE codigo = moneda_actual;

        IF idMon IS NULL THEN
            INSERT INTO Moneda (nombre, codigo)
            VALUES (moneda_actual, moneda_actual)
            RETURNING idmoneda INTO idMon;
        END IF;

        fecha_actual := (CURRENT_DATE - INTERVAL '2 months')::date;

        WHILE fecha_actual <= fecha_fin LOOP

            valor_random := ROUND((RANDOM() * 500)::numeric, 4);

            IF EXISTS (
                SELECT 1 FROM CambioMoneda 
                WHERE idmoneda = idMon AND fecha = fecha_actual
            ) THEN
                UPDATE CambioMoneda
                SET valor = valor_random
                WHERE idmoneda = idMon AND fecha = fecha_actual;

            ELSE
                INSERT INTO CambioMoneda(idmoneda, fecha, valor)
                VALUES (idMon, fecha_actual, valor_random);
            END IF;

            fecha_actual := fecha_actual + INTERVAL '1 day';
        END WHILE;

    END LOOP;

END $$;
