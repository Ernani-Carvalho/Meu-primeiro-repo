-- Modelo físico: Funcionário, Supervisor e Área
-- Regras:
--   * 1 funcionário tem no mínimo 1 e no máximo 1 supervisor (que também é funcionário)
--   * 1 supervisor supervisiona no mínimo 1 e no máximo N funcionários
--   * 1 funcionário trabalha em somente 1 área
--   * 1 área tem muitos funcionários

CREATE TABLE area (
    id_area INT         NOT NULL,
    nome    VARCHAR(50) NOT NULL,
    CONSTRAINT pk_area PRIMARY KEY (id_area),
    CONSTRAINT uq_area_nome UNIQUE (nome)
);

CREATE TABLE funcionario (
    id_funcionario INT          NOT NULL,
    nome           VARCHAR(100) NOT NULL,
    cpf            CHAR(11)     NOT NULL,
    id_supervisor  INT          NOT NULL, -- autorrelacionamento: (1,1) supervisor
    id_area        INT          NOT NULL, -- (1,1) área
    CONSTRAINT pk_funcionario PRIMARY KEY (id_funcionario),
    CONSTRAINT uq_funcionario_cpf UNIQUE (cpf),
    CONSTRAINT fk_funcionario_supervisor FOREIGN KEY (id_supervisor)
        REFERENCES funcionario (id_funcionario),
    CONSTRAINT fk_funcionario_area FOREIGN KEY (id_area)
        REFERENCES area (id_area)
);

-- Dados de exemplo
INSERT INTO area (id_area, nome) VALUES
    (1, 'Marketing'),
    (2, 'Financeiro'),
    (3, 'TI');

-- O funcionário do topo da hierarquia referencia a si mesmo como supervisor
INSERT INTO funcionario (id_funcionario, nome, cpf, id_supervisor, id_area) VALUES
    (1, 'Ana Souza',      '11111111111', 1, 3);

INSERT INTO funcionario (id_funcionario, nome, cpf, id_supervisor, id_area) VALUES
    (2, 'Bruno Lima',     '22222222222', 1, 3),
    (3, 'Carla Mendes',   '33333333333', 1, 1),
    (4, 'Diego Martins',  '44444444444', 2, 3),
    (5, 'Elisa Ferreira', '55555555555', 3, 1),
    (6, 'Fábio Rocha',    '66666666666', 1, 2);

-- Consulta: cada funcionário com seu supervisor e sua área
SELECT f.nome AS funcionario,
       s.nome AS supervisor,
       a.nome AS area
FROM funcionario f
JOIN funcionario s ON s.id_funcionario = f.id_supervisor
JOIN area a        ON a.id_area = f.id_area
ORDER BY f.id_funcionario;
