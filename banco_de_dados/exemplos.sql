INSERT INTO usuarios (nome_dispositivo, mac, geom)
VALUES (
    'Dispositivo 1',
    'AA:BB:CC:DD:EE:FF',
    ST_SetSRID(ST_MakePoint(-52.142345, -27.123456), 4326)
);
``