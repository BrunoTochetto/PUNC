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