CREATE EXTENSION IF NOT EXISTS postgis;

-- agrupamento menor (100m x 100m)
CREATE TABLE celulas (
    id BIGSERIAL PRIMARY KEY,
    cell_x BIGINT NOT NULL,
    cell_y BIGINT NOT NULL,
    id_regiao BIGINT, 
    ultima_atualizacao TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_regiao
    FOREIGN KEY (id_regiao) 
    REFERENCES regioes(id)
);

-- agrupamento menor (1000m x 1000m)
CREATE TABLE regioes (
    id BIGSERIAL PRIMARY KEY,
    region_x BIGINT NOT NULL,
    region_y BIGINT NOT NULL
);

CREATE TABLE usuarios (
    id BIGSERIAL PRIMARY KEY,
    nome_dispositivo VARCHAR(255) NOT NULL,
    mac VARCHAR(255) NOT NULL,

    -- localização geográfica original
    geom geometry(Point, 4326) NOT NULL,

    -- projeção métrica para grid fixa
    geom_3857 geometry(Point, 3857) NOT NULL,

    id_celula BIGINT,
    id_regiao BIGINT,


    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_celula 
    FOREIGN KEY (id_celula) 
    REFERENCES celulas(id),

    CONSTRAINT fk_regiao 
    FOREIGN KEY (id_regiao) 
    REFERENCES regioes(id)
);

CREATE TABLE gerentes (
    id SERIAL PRIMARY KEY,
    nome_usuario VARCHAR(255) NOT NULL,
    senha_criptografada VARCHAR(255) NOT NULL,
    email VARCHAR(255)
);

CREATE TABLE motoristas (
    id SERIAL PRIMARY KEY,
    nome_dispositivo VARCHAR(255) NOT NULL,
    mac VARCHAR(255) NOT NULL,
    identificacao_caminhao VARCHAR(255),
    tipo_lixo VARCHAR(11),
    id_gerente INT,

    CONSTRAINT fk_gerente 
    FOREIGN KEY (id_gerente) 
    REFERENCES gerentes(id)
);

CREATE TABLE trajetorias (
    id SERIAL PRIMARY KEY,
    id_motorista INT,

    CONSTRAINT fk_motorista
    FOREIGN KEY (id_motorista) 
    REFERENCES motoristas(id),
    tempo_comeco TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE localizacao_trajetorias (
    id SERIAL PRIMARY KEY,
    id_trajetoria INT,

    CONSTRAINT fk_trajetoria
    FOREIGN KEY (id_trajetoria) 
    REFERENCES trajetorias(id),

    geom_3857 geometry(Point, 3857) NOT NULL,

    data_criacao TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE UNIQUE INDEX idx_regioes_xy
ON regioes (regiao_x, regiao_y);

CREATE UNIQUE INDEX idx_celulas_xy
ON celulas (celula_x, celula_y);

CREATE INDEX idx_usuarios_geom_geog
ON usuarios
USING GIST ((geom::geography));

CREATE INDEX idx_usuarios_geom3857
ON usuarios
USING GIST (geom_3857);

CREATE INDEX idx_usuarios_celula
ON usuarios (id_celula);

CREATE INDEX idx_usuarios_regiao
ON usuarios (id_regiao);

-- =========================================================
-- 1) Todas as localizações pertencentes às trajetórias
-- View: vw_localizacoes_de_trajetos
-- =========================================================
CREATE OR REPLACE VIEW vw_localizacoes_de_trajetos AS
SELECT
    lt.id AS id_localizacao,
    lt.id_trajetoria,
    t.id_motorista,
    m.nome_dispositivo AS nome_motorista,
    m.mac,
    m.identificacao_caminhao,
    m.tipo_lixo,
    g.id AS id_gerente,
    g.nome_usuario AS nome_gerente,
    g.email AS email_gerente,

    t.tempo_comeco,
    lt.data_criacao,

    ROW_NUMBER() OVER (
        PARTITION BY lt.id_trajetoria
        ORDER BY lt.data_criacao, lt.id
    ) AS ordem_no_trajeto,

    COUNT(*) OVER (
        PARTITION BY lt.id_trajetoria
    ) AS total_localizacoes_no_trajeto,

    MIN(lt.data_criacao) OVER (
        PARTITION BY lt.id_trajetoria
    ) AS primeira_localizacao_em,

    MAX(lt.data_criacao) OVER (
        PARTITION BY lt.id_trajetoria
    ) AS ultima_localizacao_em,

    MAX(lt.data_criacao) OVER (
        PARTITION BY lt.id_trajetoria
    ) - MIN(lt.data_criacao) OVER (
        PARTITION BY lt.id_trajetoria
    ) AS duracao_trajeto,

    lt.geom_3857,
    ST_X(lt.geom_3857) AS x_3857,
    ST_Y(lt.geom_3857) AS y_3857,

    ST_Transform(lt.geom_3857, 4326) AS geom_4326,
    ST_X(ST_Transform(lt.geom_3857, 4326)) AS longitude,
    ST_Y(ST_Transform(lt.geom_3857, 4326)) AS latitude
FROM localizacao_trajetorias lt
JOIN trajetorias t
    ON t.id = lt.id_trajetoria
JOIN motoristas m
    ON m.id = t.id_motorista
LEFT JOIN gerentes g
    ON g.id = m.id_gerente;


-- =========================================================
-- 2) Todos os motoristas de um gerente
-- View: vw_motoristas_de_gerentes
-- =========================================================
CREATE OR REPLACE VIEW vw_motoristas_de_gerentes AS
SELECT
    g.id AS id_gerente,
    g.nome_usuario AS nome_gerente,
    g.email,
    m.id AS id_motorista,
    m.nome_dispositivo AS nome_motorista,
    m.mac,
    m.identificacao_caminhao,
    m.tipo_lixo
FROM gerentes g
LEFT JOIN motoristas m
    ON m.id_gerente = g.id;


-- =========================================================
-- 3) Todos os trajetos do motorista
-- View: vw_trajetos_de_motorista
-- =========================================================
CREATE OR REPLACE VIEW vw_trajetos_de_motorista AS
SELECT
    t.id AS id_trajetoria,
    t.id_motorista,
    m.nome_dispositivo AS nome_motorista,
    m.mac,
    m.identificacao_caminhao,
    m.tipo_lixo,
    t.tempo_comeco,
    COUNT(lt.id) AS quantidade_localizacoes,
    MIN(lt.data_criacao) AS primeira_localizacao_em,
    MAX(lt.data_criacao) AS ultima_localizacao_em
FROM trajetorias t
JOIN motoristas m
    ON m.id = t.id_motorista
LEFT JOIN localizacao_trajetorias lt
    ON lt.id_trajetoria = t.id
GROUP BY
    t.id,
    t.id_motorista,
    m.nome_dispositivo,
    m.mac,
    m.identificacao_caminhao,
    m.tipo_lixo,
    t.tempo_comeco;


-- =========================================================
-- 4) Quantidade de usuários por célula
-- View: vw_usuarios_em_celula
-- =========================================================
CREATE OR REPLACE VIEW vw_usuarios_em_celula AS
SELECT
    c.id AS id_celula,
    c.cell_x,
    c.cell_y,
    c.ultima_atualizacao,
    COUNT(u.id) AS quantidade_usuarios
FROM celulas c
LEFT JOIN usuarios u
    ON u.id_celula = c.id
GROUP BY
    c.id,
    c.cell_x,
    c.cell_y,
    c.ultima_atualizacao;


-- =========================================================
-- 5) Quantidade de usuários por região
-- View: vw_usuarios_em_regiao
-- =========================================================
CREATE OR REPLACE VIEW vw_usuarios_em_regiao AS
SELECT
    r.id AS id_regiao,
    r.region_x,
    r.region_y,
    COUNT(u.id) AS quantidade_usuarios
FROM regioes r
LEFT JOIN usuarios u
    ON u.id_regiao = r.id
GROUP BY
    r.id,
    r.region_x,
    r.region_y;

CREATE OR REPLACE FUNCTION trg_usuarios_set_grid()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
    v_geom_3857 geometry(Point, 3857);

    v_celula_tamanho_m CONSTANT INTEGER := 100;
    v_regiao_tamanho_m CONSTANT INTEGER := 1000;

    v_celula_x BIGINT;
    v_celula_y BIGINT;

    v_regiao_x BIGINT;
    v_regiao_y BIGINT;

    v_id_celula BIGINT;
    v_id_regiao BIGINT;
BEGIN
    IF NEW.geom IS NULL THEN
        RAISE EXCEPTION 'geom não pode ser NULL';
    END IF;

    -- Normaliza SRID
    IF ST_SRID(NEW.geom) = 0 THEN
        NEW.geom := ST_SetSRID(NEW.geom, 4326);
    ELSIF ST_SRID(NEW.geom) <> 4326 THEN
        NEW.geom := ST_Transform(NEW.geom, 4326);
    END IF;

    -- Projeta para metros
    v_geom_3857 := ST_Transform(NEW.geom, 3857);
    NEW.geom_3857 := v_geom_3857;

    -- Calcula grids
    v_celula_x := floor(ST_X(v_geom_3857) / v_celula_tamanho_m)::bigint;
    v_celula_y := floor(ST_Y(v_geom_3857) / v_celula_tamanho_m)::bigint;

    v_regiao_x := floor(ST_X(v_geom_3857) / v_regiao_tamanho_m)::bigint;
    v_regiao_y := floor(ST_Y(v_geom_3857) / v_regiao_tamanho_m)::bigint;

    -- Região (idempotente)
    INSERT INTO regioes (regiao_x, regiao_y)
    VALUES (v_regiao_x, v_regiao_y)
    ON CONFLICT (regiao_x, regiao_y) DO NOTHING;

    SELECT id
      INTO v_id_regiao
      FROM regioes
     WHERE regiao_x = v_regiao_x
       AND regiao_y = v_regiao_y;

    -- Célula (idempotente)
    INSERT INTO celulas (celula_x, celula_y)
    VALUES (v_celula_x, v_celula_y)
    ON CONFLICT (celula_x, celula_y) DO NOTHING;

    SELECT id
      INTO v_id_celula
      FROM celulas
     WHERE celula_x = v_celula_x
       AND celula_y = v_celula_y;

    -- Atribuição no usuário
    NEW.id_regiao := v_id_regiao;
    NEW.id_celula := v_id_celula;

    RETURN NEW;
END;
$$;






CREATE OR REPLACE FUNCTION achar_celulas_em_raio(
    p_lat DOUBLE PRECISION,
    p_lon DOUBLE PRECISION,
    p_raio_m DOUBLE PRECISION
)
RETURNS TABLE (
    regiao_x BIGINT,
    regiao_y BIGINT,
    celula_id BIGINT,
    celula_x BIGINT,
    celula_y BIGINT,
    quantidade_usuarios BIGINT,
    possui_usuarios BOOLEAN,
    distancia_borda_m DOUBLE PRECISION,
    distancia_centro_m DOUBLE PRECISION
)
LANGUAGE sql
STABLE
AS $$
WITH search_point AS (
    SELECT
        ST_SetSRID(ST_MakePoint(p_lon, p_lat), 4326) AS geom_4326,
        ST_Transform(ST_SetSRID(ST_MakePoint(p_lon, p_lat), 4326), 3857) AS geom_3857
),
region_bounds AS (
    SELECT
        floor((ST_X(geom_3857) - p_raio_m) / 1000)::bigint AS min_region_x,
        floor((ST_X(geom_3857) + p_raio_m) / 1000)::bigint AS max_region_x,
        floor((ST_Y(geom_3857) - p_raio_m) / 1000)::bigint AS min_region_y,
        floor((ST_Y(geom_3857) + p_raio_m) / 1000)::bigint AS max_region_y,
        geom_3857
    FROM search_point
),
candidate_cells AS (
    SELECT
        v.region_x AS regiao_x,
        v.region_y AS regiao_y,
        v.id_celula AS celula_id,
        v.cell_x AS celula_x,
        v.cell_y AS celula_y,
        v.quantidade_usuarios,
        v.possui_usuarios,
        v.cell_geom_3857,
        v.cell_centroid_3857,
        rb.geom_3857 AS search_geom_3857
    FROM region_bounds rb
    JOIN vw_usuarios_em_celula v
      ON v.region_x BETWEEN rb.min_region_x AND rb.max_region_x
     AND v.region_y BETWEEN rb.min_region_y AND rb.max_region_y
),
filtered_cells AS (
    SELECT
        cc.regiao_x,
        cc.regiao_y,
        cc.celula_id,
        cc.celula_x,
        cc.celula_y,
        cc.quantidade_usuarios,
        cc.possui_usuarios,

        ST_Distance(cc.search_geom_3857, cc.cell_geom_3857) AS distancia_borda_m,
        ST_Distance(cc.search_geom_3857, cc.cell_centroid_3857) AS distancia_centro_m
    FROM candidate_cells cc
    WHERE ST_DWithin(cc.search_geom_3857, cc.cell_geom_3857, p_raio_m)
)
SELECT
    regiao_x,
    regiao_y,
    celula_id,
    celula_x,
    celula_y,
    quantidade_usuarios,
    possui_usuarios,
    distancia_borda_m,
    distancia_centro_m
FROM filtered_cells
ORDER BY
    distancia_borda_m,
    distancia_centro_m,
    regiao_y,
    regiao_x,
    celula_y,
    celula_x;
$$;

CREATE TRIGGER usuarios_set_grid_before_ins_upd
BEFORE INSERT OR UPDATE OF geom
ON usuarios
FOR EACH ROW
EXECUTE FUNCTION trg_usuarios_set_grid();