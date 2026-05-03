-- =============================================================================
-- Exemplos: fluxo equivalente ao back-end criando um usuário
-- =============================================================================
-- O cliente envia: nome_dispositivo, mac, latitude e longitude (WGS84 / EPSG:4326).
-- O banco só precisa de nome_dispositivo, mac e geom (Point 4326).
-- O trigger trg_usuarios_set_grid preenche geom_3857, id_celula e id_regiao.
--
-- PostGIS: ST_MakePoint recebe (longitude, latitude), nunca o contrário.

-- -----------------------------------------------------------------------------
-- 1) INSERT direto (valores literais — útil para testar no psql)
-- -----------------------------------------------------------------------------
INSERT INTO usuarios (nome_dispositivo, mac, geom)
VALUES (
    'Dispositivo 1',
    'AA:BB:CC:DD:EE:FF',
    ST_SetSRID(ST_MakePoint(-52.142345, -27.123456), 4326)
);

-- -----------------------------------------------------------------------------
-- 2) Mesmo contrato, mais registros (vários “pedidos” do app)
-- -----------------------------------------------------------------------------
INSERT INTO usuarios (nome_dispositivo, mac, geom)
VALUES
    ('Sensor Lixeira A', '11:22:33:44:55:01', ST_SetSRID(ST_MakePoint(-48.5480, -27.5954), 4326)),
    ('Sensor Lixeira B', '11:22:33:44:55:02', ST_SetSRID(ST_MakePoint(-48.5490, -27.5960), 4326)),
    ('Totem Centro',     'AA:BB:CC:00:00:01', ST_SetSRID(ST_MakePoint(-48.5000, -27.6000), 4326));

-- -----------------------------------------------------------------------------
-- 3) Como no back-end com query parametrizada ($1..$4 — drivers costumam usar ? ou :nome)
--    Ordem sugerida dos parâmetros: nome_dispositivo, mac, latitude, longitude
-- -----------------------------------------------------------------------------
-- Exemplo conceitual (não executar assim no psql sem definir variáveis):
--
-- INSERT INTO usuarios (nome_dispositivo, mac, geom)
-- VALUES (
--     $1,
--     $2,
--     ST_SetSRID(ST_MakePoint($4, $3), 4326)
-- );

-- -----------------------------------------------------------------------------
-- 4) Simulação com DO $$ ... $$ (útil para testar ordem lat/lng sem cliente HTTP)
-- -----------------------------------------------------------------------------
DO $$
DECLARE
    p_nome TEXT := 'Dispositivo DO-block';
    p_mac  TEXT := 'DE:AD:BE:EF:00:01';
    p_lat  DOUBLE PRECISION := -27.123456;
    p_lng  DOUBLE PRECISION := -52.142345;
BEGIN
    INSERT INTO usuarios (nome_dispositivo, mac, geom)
    VALUES (
        p_nome,
        p_mac,
        ST_SetSRID(ST_MakePoint(p_lng, p_lat), 4326)
    );
END $$;

-- -----------------------------------------------------------------------------
-- 5) Retorno ao cliente após insert (id + grade atribuída pelo trigger)
-- -----------------------------------------------------------------------------
INSERT INTO usuarios (nome_dispositivo, mac, geom)
VALUES (
    'Retorno API',
    '00:11:22:33:44:55',
    ST_SetSRID(ST_MakePoint(-52.14, -27.12), 4326)
)
RETURNING
    id,
    nome_dispositivo,
    mac,
    ST_Y(geom) AS latitude,
    ST_X(geom) AS longitude,
    id_celula,
    id_regiao,
    created_at;

-- -----------------------------------------------------------------------------
-- 6) Consultas às views (célula: agregado por célula; região: uma linha por usuário)
-- -----------------------------------------------------------------------------
SELECT * FROM vw_usuarios_em_celula WHERE quantidade_usuarios > 0 LIMIT 10;
SELECT * FROM vw_usuarios_em_regiao WHERE id_usuario IS NOT NULL;
