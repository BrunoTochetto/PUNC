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