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