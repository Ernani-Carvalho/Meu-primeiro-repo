-- =====================================================
-- EXTRA - Exercício 4: Empresa e Estrutura de Setores
-- =====================================================

CREATE DATABASE IF NOT EXISTS sprint2;

USE sprint2;

-- Apaga as tabelas se já existirem (para poder rodar o script de novo)
-- Atenção: a tabela funcionario do Exercício 2 tem o mesmo nome e também é substituída
-- funcionario e projeto são apagadas antes de setor porque referenciam setor
DROP TABLE IF EXISTS funcionario;

DROP TABLE IF EXISTS projeto;

DROP TABLE IF EXISTS setor;

-- =====================================================
-- MODELAGEM E CRIAÇÃO
-- =====================================================

-- A tabela setor é criada primeiro porque funcionario e projeto referenciam ela
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

-- Inserir os setores (os setores superiores são cadastrados primeiro)
-- Diretoria não é subordinada a ninguém; TI e Financeiro respondem à Diretoria;
-- Desenvolvimento e Infraestrutura respondem à TI; Contabilidade responde ao Financeiro
INSERT INTO setor (nmSetor, sigla, fkSetorSuperior) VALUES
('Diretoria',                'DIR',   NULL),
('Tecnologia da Informação', 'TI',    1),
('Financeiro',               'FIN',   1),
('Desenvolvimento',          'DEV',   2),
('Infraestrutura',           'INFRA', 2),
('Contabilidade',            'CONT',  3);

-- Inserir os funcionários (Contabilidade fica sem funcionários)
-- Setores: 1 = DIR, 2 = TI, 3 = FIN, 4 = DEV, 5 = INFRA, 6 = CONT
INSERT INTO funcionario (nmFuncionario, email, salario, dtAdmissao, fkSetor) VALUES
('Ana Paula',     'ana.paula@empresa.com',     15000.00, '2014-02-10', 1),
('Bruno Costa',   'bruno.costa@empresa.com',   9500.00,  '2018-06-01', 2),
('Carla Mendes',  'carla.mendes@empresa.com',  7800.00,  '2020-03-15', 4),
('Diego Souza',   'diego.souza@empresa.com',   6200.00,  '2021-09-01', 4),
('Elisa Martins', 'elisa.martins@empresa.com', 4500.00,  '2023-01-16', 4),
('Felipe Rocha',  'felipe.rocha@empresa.com',  5200.00,  '2022-04-04', 5),
('Gabriela Lima', 'gabriela.lima@empresa.com', 3800.00,  '2024-07-08', 3);

-- Inserir os projetos (Desenvolvimento é responsável por dois)
INSERT INTO projeto (nmProjeto, descricao, dtInicio, dtPrevisaoTermino, fkSetor) VALUES
('Novo Portal',         'Desenvolvimento do novo portal do cliente',            '2025-02-01', '2025-12-15', 4),
('App Mobile',          'Aplicativo de autoatendimento para clientes',          '2025-05-05', '2026-03-31', 4),
('Migração para Nuvem', 'Migração dos servidores locais para a nuvem',          '2025-01-10', '2025-10-30', 5),
('Orçamento 2026',      'Planejamento do orçamento anual',                      '2025-08-01', '2025-11-30', 3),
('Auditoria Fiscal',    'Revisão das obrigações fiscais',                       '2025-03-01', '2025-06-30', 6),
('Plano Estratégico',   'Definição das metas da empresa para os próximos anos', '2025-01-02', '2025-12-31', 1);

-- =====================================================
-- CONSULTAS E MANIPULAÇÃO
-- =====================================================

-- a) Nome do funcionário e nome do seu setor
SELECT f.nmFuncionario,
s.nmSetor
FROM funcionario f
JOIN setor s ON f.fkSetor = s.pkSetor;

-- b) Nome do projeto e nome do setor responsável
SELECT p.nmProjeto,
s.nmSetor
FROM projeto p
JOIN setor s ON p.fkSetor = s.pkSetor;

-- c) Funcionários admitidos após 01/01/2021, com o setor
SELECT f.nmFuncionario,
f.dtAdmissao,
s.nmSetor
FROM funcionario f
JOIN setor s ON f.fkSetor = s.pkSetor
WHERE f.dtAdmissao > '2021-01-01';

-- d) Setores subordinados e seus setores superiores (só quem tem superior)
SELECT s.nmSetor AS setor,
sup.nmSetor AS setorSuperior
FROM setor s
JOIN setor sup ON s.fkSetorSuperior = sup.pkSetor;

-- e) Todos os setores e, quando existir, o setor superior
SELECT s.nmSetor AS setor,
sup.nmSetor AS setorSuperior
FROM setor s
LEFT JOIN setor sup ON s.fkSetorSuperior = sup.pkSetor;

-- f) Setores subordinados à Tecnologia da Informação (pkSetor = 2)
SELECT nmSetor,
sigla
FROM setor
WHERE fkSetorSuperior = 2;

-- g) Todos os setores e seus funcionários, incluindo setores sem funcionários
SELECT s.nmSetor,
f.nmFuncionario
FROM setor s
LEFT JOIN funcionario f ON f.fkSetor = s.pkSetor;

-- h) Funcionário, salário, setor e classificação salarial
-- Faixas: até R$ 5.000,00 = Faixa Baixa; até R$ 10.000,00 = Faixa Média; acima disso = Faixa Alta
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

-- i) Funcionários dos setores Desenvolvimento e Infraestrutura, usando IN
SELECT f.nmFuncionario,
s.nmSetor
FROM funcionario f
JOIN setor s ON f.fkSetor = s.pkSetor
WHERE s.nmSetor IN ('Desenvolvimento', 'Infraestrutura');

-- j) Infraestrutura passa a responder diretamente à Diretoria
UPDATE setor SET fkSetorSuperior = 1 WHERE pkSetor = 5;

-- k) Financeiro deixa de ter setor superior
UPDATE setor SET fkSetorSuperior = NULL WHERE pkSetor = 3;

-- Conferir a hierarquia final
SELECT s.nmSetor AS setor,
sup.nmSetor AS setorSuperior
FROM setor s
LEFT JOIN setor sup ON s.fkSetorSuperior = sup.pkSetor;
