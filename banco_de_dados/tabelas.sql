CREATE EXTENSION IF NOT EXISTS postgis;

-- agrupamento menor (1000m x 1000m)
CREATE TABLE regioes (
    id BIGSERIAL PRIMARY KEY,
    region_x BIGINT NOT NULL,
    region_y BIGINT NOT NULL
);

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

