CREATE DATABASE IF NOT EXISTS sprint2;

USE sprint2;

CREATE TABLE setor (
pkSetor         INT PRIMARY KEY AUTO_INCREMENT,
nmSetor         VARCHAR(45) NOT NULL,
sigla           VARCHAR(10) NOT NULL UNIQUE,
fkSetorSuperior INT,
FOREIGN KEY (fkSetorSuperior) REFERENCES setor(pkSetor)
);

CREATE TABLE funcionario (
pkFuncionario INT PRIMARY KEY AUTO_INCREMENT,
nmFuncionario VARCHAR(45) NOT NULL,
email         VARCHAR(100) NOT NULL UNIQUE,
salario       DECIMAL(8,2) NOT NULL,
dtAdmissao    DATE NOT NULL,
fkSetor       INT NOT NULL,
FOREIGN KEY (fkSetor) REFERENCES setor(pkSetor)
);

CREATE TABLE projeto (
pkProjeto         INT PRIMARY KEY AUTO_INCREMENT,
nmProjeto         VARCHAR(45) NOT NULL,
descricao         VARCHAR(200),
dtInicio          DATE NOT NULL,
dtPrevisaoTermino DATE,
fkSetor           INT NOT NULL,
CONSTRAINT chkDatas CHECK (dtPrevisaoTermino >= dtInicio),
FOREIGN KEY (fkSetor) REFERENCES setor(pkSetor)
);

INSERT INTO setor (nmSetor, sigla, fkSetorSuperior) VALUES
('Diretoria',                'DIR',   NULL),
('Tecnologia da Informação', 'TI',    1),
('Financeiro',               'FIN',   1),
('Desenvolvimento',          'DEV',   2),
('Infraestrutura',           'INFRA', 2),
('Contabilidade',            'CONT',  3);

INSERT INTO funcionario (nmFuncionario, email, salario, dtAdmissao, fkSetor) VALUES
('Ana Paula',     'ana.paula@empresa.com',     15000.00, '2014-02-10', 1),
('Bruno Costa',   'bruno.costa@empresa.com',   9500.00,  '2018-06-01', 2),
('Carla Mendes',  'carla.mendes@empresa.com',  7800.00,  '2020-03-15', 4),
('Diego Souza',   'diego.souza@empresa.com',   6200.00,  '2021-09-01', 4),
('Elisa Martins', 'elisa.martins@empresa.com', 4500.00,  '2023-01-16', 4),
('Felipe Rocha',  'felipe.rocha@empresa.com',  5200.00,  '2022-04-04', 5),
('Gabriela Lima', 'gabriela.lima@empresa.com', 3800.00,  '2024-07-08', 3);

INSERT INTO projeto (nmProjeto, descricao, dtInicio, dtPrevisaoTermino, fkSetor) VALUES
('Novo Portal',         'Desenvolvimento do novo portal do cliente',            '2025-02-01', '2025-12-15', 4),
('App Mobile',          'Aplicativo de autoatendimento para clientes',          '2025-05-05', '2026-03-31', 4),
('Migração para Nuvem', 'Migração dos servidores locais para a nuvem',          '2025-01-10', '2025-10-30', 5),
('Orçamento 2026',      'Planejamento do orçamento anual',                      '2025-08-01', '2025-11-30', 3),
('Auditoria Fiscal',    'Revisão das obrigações fiscais',                       '2025-03-01', '2025-06-30', 6),
('Plano Estratégico',   'Definição das metas da empresa para os próximos anos', '2025-01-02', '2025-12-31', 1);

SELECT f.nmFuncionario,
s.nmSetor
FROM funcionario f
JOIN setor s ON f.fkSetor = s.pkSetor;

SELECT p.nmProjeto,
s.nmSetor
FROM projeto p
JOIN setor s ON p.fkSetor = s.pkSetor;

SELECT f.nmFuncionario,
f.dtAdmissao,
s.nmSetor
FROM funcionario f
JOIN setor s ON f.fkSetor = s.pkSetor
WHERE f.dtAdmissao > '2021-01-01';

SELECT s.nmSetor AS setor,
sup.nmSetor AS setorSuperior
FROM setor s
JOIN setor sup ON s.fkSetorSuperior = sup.pkSetor;

SELECT s.nmSetor AS setor,
sup.nmSetor AS setorSuperior
FROM setor s
LEFT JOIN setor sup ON s.fkSetorSuperior = sup.pkSetor;

SELECT nmSetor,
sigla
FROM setor
WHERE fkSetorSuperior = 2;

SELECT s.nmSetor,
f.nmFuncionario
FROM setor s
LEFT JOIN funcionario f ON f.fkSetor = s.pkSetor;

SELECT f.nmFuncionario,
f.salario,
s.nmSetor,
CASE
WHEN f.salario <= 5000 THEN 'Faixa Baixa'
WHEN f.salario <= 10000 THEN 'Faixa Média'
ELSE 'Faixa Alta'
END AS classificacao
FROM funcionario f
JOIN setor s ON f.fkSetor = s.pkSetor;

SELECT f.nmFuncionario,
s.nmSetor
FROM funcionario f
JOIN setor s ON f.fkSetor = s.pkSetor
WHERE s.nmSetor IN ('Desenvolvimento', 'Infraestrutura');

UPDATE setor SET fkSetorSuperior = 1 WHERE pkSetor = 5;

UPDATE setor SET fkSetorSuperior = NULL WHERE pkSetor = 3;

SELECT s.nmSetor AS setor,
sup.nmSetor AS setorSuperior
FROM setor s
LEFT JOIN setor sup ON s.fkSetorSuperior = sup.pkSetor;
