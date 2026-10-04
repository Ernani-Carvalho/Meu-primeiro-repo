-- =====================================================
-- EXTRA - Exercício 2: Funcionários e Supervisores
-- =====================================================

CREATE DATABASE IF NOT EXISTS sprint2;

USE sprint2;

-- Apaga as tabelas se já existirem (para poder rodar o script de novo)
-- A tabela funcionario é apagada primeiro porque ela referencia a tabela departamento
DROP TABLE IF EXISTS funcionario;

DROP TABLE IF EXISTS departamento;

-- =====================================================
-- MODELAGEM E CRIAÇÃO
-- =====================================================

-- A tabela departamento é criada primeiro porque a tabela funcionario referencia ela
CREATE TABLE departamento (
pkDepartamento INT PRIMARY KEY AUTO_INCREMENT,
nmDepartamento VARCHAR(45) NOT NULL,
andar          INT NOT NULL
);

CREATE TABLE funcionario (
pkFuncionario  INT PRIMARY KEY AUTO_INCREMENT,
nmFuncionario  VARCHAR(45) NOT NULL,
email          VARCHAR(100) NOT NULL UNIQUE,
salario        DECIMAL(8,2) NOT NULL,
dtAdmissao     DATE NOT NULL,
fkDepartamento INT NOT NULL,
fkSupervisor   INT,
FOREIGN KEY (fkDepartamento) REFERENCES departamento(pkDepartamento),
FOREIGN KEY (fkSupervisor) REFERENCES funcionario(pkFuncionario)
);

-- Inserir os departamentos
INSERT INTO departamento (nmDepartamento, andar) VALUES
('TI',               3),
('Financeiro',       2),
('Recursos Humanos', 1),
('Marketing',        4);

-- Inserir os funcionários (os supervisores são cadastrados primeiro)
-- Departamentos: 1 = TI, 2 = Financeiro, 3 = Recursos Humanos, 4 = Marketing
-- Supervisores: 1 = Ana Souza, 2 = Carlos Lima, 7 = Gabriel Santos
INSERT INTO funcionario (nmFuncionario, email, salario, dtAdmissao, fkDepartamento, fkSupervisor) VALUES
('Ana Souza',       'ana.souza@empresa.com',       12000.00, '2015-03-10', 1, NULL),
('Carlos Lima',     'carlos.lima@empresa.com',     11000.00, '2016-07-01', 2, NULL),
('Bruno Alves',     'bruno.alves@empresa.com',     6500.00,  '2019-02-15', 1, 1),
('Daniela Rocha',   'daniela.rocha@empresa.com',   7200.00,  '2020-08-03', 1, 1),
('Eduardo Martins', 'eduardo.martins@empresa.com', 4800.00,  '2021-01-20', 2, 2),
('Fernanda Costa',  'fernanda.costa@empresa.com',  3500.00,  '2022-05-09', 2, 2),
('Gabriel Santos',  'gabriel.santos@empresa.com',  3900.00,  '2023-04-17', 3, NULL),
('Helena Dias',     'helena.dias@empresa.com',     2800.00,  '2024-02-01', 4, 7);

-- =====================================================
-- CONSULTAS E MANIPULAÇÃO
-- =====================================================

-- a) Nome de cada funcionário e o nome do seu departamento
SELECT f.nmFuncionario,
d.nmDepartamento
FROM funcionario f
JOIN departamento d ON f.fkDepartamento = d.pkDepartamento;

-- b) Nome, salário e departamento dos admitidos após 01/01/2020
SELECT f.nmFuncionario,
f.salario,
d.nmDepartamento
FROM funcionario f
JOIN departamento d ON f.fkDepartamento = d.pkDepartamento
WHERE f.dtAdmissao > '2020-01-01';

-- c) Funcionários dos departamentos TI e Financeiro, usando IN
SELECT f.nmFuncionario,
d.nmDepartamento
FROM funcionario f
JOIN departamento d ON f.fkDepartamento = d.pkDepartamento
WHERE d.nmDepartamento IN ('TI', 'Financeiro');

-- d) Nome, salário e departamento, do maior salário para o menor
SELECT f.nmFuncionario,
f.salario,
d.nmDepartamento
FROM funcionario f
JOIN departamento d ON f.fkDepartamento = d.pkDepartamento
ORDER BY f.salario DESC;

-- e) Funcionários que possuem supervisor e o nome do supervisor
SELECT f.nmFuncionario AS funcionario,
s.nmFuncionario AS supervisor
FROM funcionario f
JOIN funcionario s ON f.fkSupervisor = s.pkFuncionario;

-- f) Nome e e-mail dos funcionários supervisionados por Ana Souza (pkFuncionario = 1)
SELECT nmFuncionario,
email
FROM funcionario
WHERE fkSupervisor = 1;

-- g) Funcionários cujo nome do supervisor começa com a letra C
SELECT f.nmFuncionario AS funcionario,
s.nmFuncionario AS supervisor
FROM funcionario f
JOIN funcionario s ON f.fkSupervisor = s.pkFuncionario
WHERE s.nmFuncionario LIKE 'C%';

-- h) Funcionário, supervisor e classificação salarial
-- Faixas: até R$ 4.000,00 = Faixa Baixa; até R$ 8.000,00 = Faixa Média; acima disso = Faixa Alta
SELECT f.nmFuncionario AS funcionario,
s.nmFuncionario AS supervisor,
f.salario,
CASE
WHEN f.salario <= 4000 THEN 'Faixa Baixa'
WHEN f.salario <= 8000 THEN 'Faixa Média'
ELSE 'Faixa Alta'
END AS classificacao
FROM funcionario f
LEFT JOIN funcionario s ON f.fkSupervisor = s.pkFuncionario;

-- i) Atualizar o supervisor de Helena Dias para Carlos Lima
UPDATE funcionario SET fkSupervisor = 2 WHERE pkFuncionario = 8;

-- j) Remover o supervisor de Daniela Rocha
UPDATE funcionario SET fkSupervisor = NULL WHERE pkFuncionario = 4;

-- k) Excluir um funcionário que não seja supervisor de ninguém
-- Conferir quem não é supervisor de ninguém
SELECT pkFuncionario,
nmFuncionario
FROM funcionario
WHERE pkFuncionario NOT IN (SELECT fkSupervisor FROM funcionario WHERE fkSupervisor IS NOT NULL);

-- Excluir Fernanda Costa (pkFuncionario = 6), que não supervisiona ninguém
DELETE FROM funcionario WHERE pkFuncionario = 6;

-- Conferir a tabela final
SELECT * FROM funcionario;
