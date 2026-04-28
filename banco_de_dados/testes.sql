Pegar em raio -> Retornando usuários

CREATE OR REPLACE FUNCTION achar_usuarios_em_raio(
    p_lat DOUBLE PRECISION,
    p_lon DOUBLE PRECISION,
    p_raio_m DOUBLE PRECISION
)
RETURNS TABLE (
    regiao_x BIGINT,
    regiao_y BIGINT,
    celula_x BIGINT,
    celula_y BIGINT,
    usuario_id BIGINT,
    nome_dispositivo TEXT,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    distancia_m DOUBLE PRECISION
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
        geom_4326,
        geom_3857
    FROM search_point
),
candidate_regions AS (
    SELECT
        r.id AS id_regiao,
        r.region_x,
        r.region_y,
        rb.geom_4326,
        rb.geom_3857
    FROM region_bounds rb
    JOIN regioes r
      ON r.region_x BETWEEN rb.min_region_x AND rb.max_region_x
     AND r.region_y BETWEEN rb.min_region_y AND rb.max_region_y
),
candidate_cells AS (
    SELECT
        c.id AS id_celula,
        c.cell_x,
        c.cell_y,
        cr.id_regiao,
        cr.region_x,
        cr.region_y,
        cr.geom_4326,
        cr.geom_3857
    FROM candidate_regions cr
    JOIN celulas c
      ON floor(c.cell_x / 10.0)::bigint = cr.region_x
     AND floor(c.cell_y / 10.0)::bigint = cr.region_y
    WHERE ST_DWithin(
        cr.geom_3857,
        ST_MakeEnvelope(
            c.cell_x * 100,
            c.cell_y * 100,
            (c.cell_x + 1) * 100,
            (c.cell_y + 1) * 100,
            3857
        ),
        p_raio_m
    )
),
candidate_users AS (
    SELECT
        u.id,
        u.nome_dispositivo,
        u.geom,
        cc.region_x,
        cc.region_y,
        cc.cell_x,
        cc.cell_y,
        cc.geom_4326
    FROM candidate_cells cc
    JOIN usuarios u
      ON u.id_celula = cc.id_celula
     AND u.id_regiao = cc.id_regiao
),
filtered_users AS (
    SELECT
        cu.region_x AS regiao_x,
        cu.region_y AS regiao_y,
        cu.cell_x AS celula_x,
        cu.cell_y AS celula_y,
        cu.id AS usuario_id,
        cu.nome_dispositivo::text,
        ST_Y(cu.geom) AS latitude,
        ST_X(cu.geom) AS longitude,
        ST_Distance(cu.geom::geography, cu.geom_4326::geography) AS distancia_m
    FROM candidate_users cu
    WHERE ST_DWithin(cu.geom::geography, cu.geom_4326::geography, p_raio_m)
)
SELECT
    regiao_x,
    regiao_y,
    celula_x,
    celula_y,
    usuario_id,
    nome_dispositivo,
    latitude,
    longitude,
    distancia_m
FROM filtered_users
ORDER BY distancia_m, regiao_y, regiao_x, celula_y, celula_x;
$$;