-- =========================================================
-- 1) Todas as localizações pertencentes às trajetórias
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
-- 4) View: vw_usuarios_em_celula — uma linha por célula (contagem + geometria da grade)
--     Usada por achar_celulas_em_raio (JOIN nesta view).
-- =========================================================
CREATE OR REPLACE VIEW vw_usuarios_em_celula AS
SELECT
    c.id AS id_celula,
    c.cell_x,
    c.cell_y,
    r.region_x,
    r.region_y,
    c.ultima_atualizacao,
    COUNT(u.id) AS quantidade_usuarios,
    ST_MakeEnvelope(
        c.cell_x * 100::double precision,
        c.cell_y * 100::double precision,
        (c.cell_x + 1) * 100::double precision,
        (c.cell_y + 1) * 100::double precision,
        3857
    ) AS cell_geom_3857,
    ST_Centroid(
        ST_MakeEnvelope(
            c.cell_x * 100::double precision,
            c.cell_y * 100::double precision,
            (c.cell_x + 1) * 100::double precision,
            (c.cell_y + 1) * 100::double precision,
            3857
        )
    ) AS cell_centroid_3857
FROM celulas c
LEFT JOIN regioes r
    ON r.id = c.id_regiao
LEFT JOIN usuarios u
    ON u.id_celula = c.id
GROUP BY
    c.id,
    c.cell_x,
    c.cell_y,
    r.region_x,
    r.region_y,
    c.ultima_atualizacao;


-- =========================================================
-- 5) Uma linha por usuário na região
-- =========================================================
CREATE OR REPLACE VIEW vw_usuarios_em_regiao AS
SELECT
    r.id AS id_regiao,
    r.region_x,
    r.region_y,
    u.id AS id_usuario,
    u.nome_dispositivo,
    u.mac,
    u.created_at
FROM regioes r
LEFT JOIN usuarios u
    ON u.id_regiao = r.id;


-- =========================================================
-- 6) Todas as áreas de atuação de um gerente
-- =========================================================
CREATE OR REPLACE VIEW vw_areas_de_atuacao_de_gerentes AS
SELECT
    g.id AS id_gerente,
    g.nome_usuario AS nome_gerente,
    g.email,
    a.id AS id_area_atuacao,
    a.cep
FROM gerentes g
LEFT JOIN area_de_atuacao a
    ON a.id_gerente = g.id;


-- =========================================================
-- 7) Horários de coleta com gerente e área (CEP)
-- =========================================================
CREATE OR REPLACE VIEW vw_horarios_coleta AS
SELECT
    hc.id AS id_horario,
    hc.horario_estimado,
    hc.dia_semana,
    hc.data_criacao,
    hc.tipo_lixo,
    hc.comentarios,
    g.id AS id_gerente,
    g.nome_usuario AS nome_gerente,
    g.email AS email_gerente,
    a.id AS id_area_atuacao,
    a.cep
FROM horarios_coleta hc
JOIN gerentes g
    ON g.id = hc.id_gerente
LEFT JOIN area_de_atuacao a
    ON a.id = hc.id_area_atuacao;