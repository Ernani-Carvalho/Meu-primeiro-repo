-- =====================================================
-- EXTRA - Exercício 3: Escola de Tecnologia
-- =====================================================

CREATE DATABASE IF NOT EXISTS sprint2;

USE sprint2;

-- Apaga as tabelas se já existirem (para poder rodar o script de novo)
-- A ordem é a inversa da criação: aluno referencia turma, e turma referencia curso
DROP TABLE IF EXISTS aluno;

DROP TABLE IF EXISTS turma;

DROP TABLE IF EXISTS curso;

-- =====================================================
-- MODELAGEM E CRIAÇÃO
-- =====================================================

-- Ordem de criação: curso, depois turma (referencia curso), depois aluno (referencia turma)
CREATE TABLE curso (
pkCurso      INT PRIMARY KEY AUTO_INCREMENT,
nmCurso      VARCHAR(45) NOT NULL,
sigla        VARCHAR(10) NOT NULL UNIQUE,
qtdSemestres INT NOT NULL,
CONSTRAINT chkSemestres CHECK (qtdSemestres > 0)
);

-- semestreIngresso no formato AAAA-S (exemplo: 2024-1 = primeiro semestre de 2024)
CREATE TABLE turma (
pkTurma          INT PRIMARY KEY AUTO_INCREMENT,
codigo           VARCHAR(10) NOT NULL UNIQUE,
semestreIngresso CHAR(6) NOT NULL,
fkCurso          INT NOT NULL,
FOREIGN KEY (fkCurso) REFERENCES curso(pkCurso)
);

CREATE TABLE aluno (
pkAluno      INT PRIMARY KEY AUTO_INCREMENT,
ra           VARCHAR(10) NOT NULL UNIQUE,
nmAluno      VARCHAR(45) NOT NULL,
email        VARCHAR(100) NOT NULL UNIQUE,
dtNascimento DATE NOT NULL,
fkTurma      INT NOT NULL,
FOREIGN KEY (fkTurma) REFERENCES turma(pkTurma)
);

-- Inserir os cursos (Sistemas de Informação fica sem turma)
INSERT INTO curso (nmCurso, sigla, qtdSemestres) VALUES
('Análise e Desenvolvimento de Sistemas', 'ADS', 4),
('Ciência da Computação',                 'CCO', 8),
('Sistemas de Informação',                'SIS', 8);

-- Inserir as turmas
-- Cursos: 1 = ADS, 2 = CCO, 3 = SIS
INSERT INTO turma (codigo, semestreIngresso, fkCurso) VALUES
('ADS-23A', '2023-1', 1),
('ADS-25A', '2025-1', 1),
('CCO-24A', '2024-1', 2),
('CCO-24B', '2024-2', 2);

-- Inserir os alunos
-- Turmas: 1 = ADS-23A, 2 = ADS-25A, 3 = CCO-24A, 4 = CCO-24B
INSERT INTO aluno (ra, nmAluno, email, dtNascimento, fkTurma) VALUES
('01231001', 'Lucas Pereira',   'lucas.pereira@escola.com',   '2004-05-12', 1),
('01231002', 'Mariana Silva',   'mariana.silva@escola.com',   '2003-11-02', 1),
('01231003', 'Pedro Henrique',  'pedro.henrique@escola.com',  '2004-01-25', 1),
('01251001', 'Julia Fernandes', 'julia.fernandes@escola.com', '2006-07-19', 2),
('01251002', 'Rafael Gomes',    'rafael.gomes@escola.com',    '2006-03-08', 2),
('02241001', 'Beatriz Ramos',   'beatriz.ramos@escola.com',   '2005-09-30', 3),
('02241002', 'Thiago Nunes',    'thiago.nunes@escola.com',    '2005-12-14', 3),
('02242001', 'Camila Torres',   'camila.torres@escola.com',   '2005-04-22', 4);

-- =====================================================
-- CONSULTAS E MANIPULAÇÃO
-- =====================================================

-- a) Código da turma e o nome do curso
SELECT t.codigo,
c.nmCurso
FROM turma t
JOIN curso c ON t.fkCurso = c.pkCurso;

-- b) Nome do aluno, RA, código da turma e nome do curso (as três tabelas)
SELECT a.nmAluno,
a.ra,
t.codigo,
c.nmCurso
FROM aluno a
JOIN turma t ON a.fkTurma = t.pkTurma
JOIN curso c ON t.fkCurso = c.pkCurso;

-- c) Alunos do curso ADS, com a turma
SELECT a.nmAluno,
t.codigo
FROM aluno a
JOIN turma t ON a.fkTurma = t.pkTurma
JOIN curso c ON t.fkCurso = c.pkCurso
WHERE c.sigla = 'ADS';

-- d) Nome do aluno, turma e classificação pelo semestre de ingresso
-- Critérios: ingresso antes de 2024 = Veterano; em 2024 = Intermediário; de 2025 em diante = Calouro
SELECT a.nmAluno,
t.codigo,
t.semestreIngresso,
CASE
WHEN t.semestreIngresso < '2024-1' THEN 'Veterano'
WHEN t.semestreIngresso < '2025-1' THEN 'Intermediário'
ELSE 'Calouro'
END AS classificacao
FROM aluno a
JOIN turma t ON a.fkTurma = t.pkTurma;

-- e) Todos os cursos e suas turmas, incluindo cursos sem turma
SELECT c.nmCurso,
t.codigo
FROM curso c
LEFT JOIN turma t ON t.fkCurso = c.pkCurso;

-- f) Adicionar o campo telefone
ALTER TABLE aluno ADD COLUMN telefone VARCHAR(15);

-- g) Atualizar o telefone de 2 alunos
UPDATE aluno SET telefone = '(11) 91234-5678' WHERE pkAluno = 1;

UPDATE aluno SET telefone = '(11) 98765-4321' WHERE pkAluno = 2;

-- Conferir a tabela final
SELECT * FROM aluno;
