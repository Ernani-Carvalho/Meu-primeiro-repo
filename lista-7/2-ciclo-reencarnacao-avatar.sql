-- =====================================================
-- Lista 7 - Exercício 2: O Ciclo de Reencarnação do Avatar
-- =====================================================

CREATE DATABASE IF NOT EXISTS sprint2;

USE sprint2;

-- Apaga as tabelas se já existirem (para poder rodar o script de novo)
-- A tabela avatar é apagada primeiro porque ela referencia a tabela nacao
DROP TABLE IF EXISTS avatar;

DROP TABLE IF EXISTS nacao;

-- =====================================================
-- CRIAÇÃO DAS TABELAS
-- =====================================================

-- A tabela nacao é criada primeiro porque a tabela avatar referencia ela
CREATE TABLE nacao (
pkNacao    INT PRIMARY KEY AUTO_INCREMENT,
nmNacao    VARCHAR(45) NOT NULL,
nmElemento VARCHAR(45) NOT NULL
);

CREATE TABLE avatar (
pkAvatar     INT PRIMARY KEY AUTO_INCREMENT,
nmAvatar     VARCHAR(45) NOT NULL,
fkNacao      INT NOT NULL,
fkAntecessor INT UNIQUE,
FOREIGN KEY (fkNacao) REFERENCES nacao(pkNacao),
FOREIGN KEY (fkAntecessor) REFERENCES avatar(pkAvatar)
);

-- =====================================================
-- INSERÇÃO DOS DADOS
-- =====================================================

-- 1. Inserir as quatro nações
INSERT INTO nacao (nmNacao, nmElemento) VALUES
('Nômades do Ar',  'Ar'),
('Tribo da Água',  'Água'),
('Reino da Terra', 'Terra'),
('Nação do Fogo',  'Fogo');

-- 2. Inserir os oito avatares, cada um referenciando o anterior
-- Nações: 1 = Nômades do Ar, 2 = Tribo da Água, 3 = Reino da Terra, 4 = Nação do Fogo
INSERT INTO avatar (nmAvatar, fkNacao, fkAntecessor) VALUES
('Wan',      1, NULL),
('Szeto',    4, 1),
('Yangchen', 1, 2),
('Kuruk',    2, 3),
('Kyoshi',   3, 4),
('Roku',     4, 5),
('Aang',     1, 6),
('Korra',    2, 7);

-- =====================================================
-- LEITURA DO PERGAMINHO
-- =====================================================

-- 1. Avatar, nação, elemento e antecessor (o primeiro aparece com o antecessor em branco)
SELECT a.nmAvatar AS avatar,
n.nmNacao AS nacao,
n.nmElemento AS elemento,
ant.nmAvatar AS antecessor
FROM avatar a
JOIN nacao n ON a.fkNacao = n.pkNacao
LEFT JOIN avatar ant ON a.fkAntecessor = ant.pkAvatar
ORDER BY a.pkAvatar;

-- 2. Frase: Avatar [NOME] sucedeu Avatar [NOME DO ANTECESSOR]
SELECT CONCAT('Avatar ', a.nmAvatar, ' sucedeu Avatar ', ant.nmAvatar) AS frase
FROM avatar a
JOIN avatar ant ON a.fkAntecessor = ant.pkAvatar
ORDER BY a.pkAvatar;

-- 3. Avatar, seu elemento, seu antecessor e o elemento do antecessor
SELECT a.nmAvatar AS avatar,
n.nmElemento AS elemento,
ant.nmAvatar AS antecessor,
nAnt.nmElemento AS elementoAntecessor
FROM avatar a
JOIN nacao n ON a.fkNacao = n.pkNacao
JOIN avatar ant ON a.fkAntecessor = ant.pkAvatar
JOIN nacao nAnt ON ant.fkNacao = nAnt.pkNacao
ORDER BY a.pkAvatar;

-- 4. Avatar e a Época
SELECT nmAvatar,
CASE
WHEN nmAvatar IN ('Wan', 'Szeto', 'Yangchen', 'Kuruk') THEN 'Era Antiga'
WHEN nmAvatar IN ('Kyoshi', 'Roku') THEN 'Era Clássica'
ELSE 'Era Moderna'
END AS Época
FROM avatar
ORDER BY pkAvatar;

-- =====================================================
-- AJUSTES NO CICLO
-- =====================================================

-- 1. Atualizar o nome da Tribo da Água
UPDATE nacao SET nmNacao = 'Tribo da Água do Norte e do Sul' WHERE pkNacao = 2;

-- 2. Remover o último avatar do ciclo (nenhum outro avatar o referencia como antecessor)
-- Conferir qual é: o resultado deve ser Korra (pkAvatar = 8)
SELECT *
FROM avatar
WHERE pkAvatar NOT IN (SELECT fkAntecessor FROM avatar WHERE fkAntecessor IS NOT NULL);

DELETE FROM avatar WHERE pkAvatar = 8;

-- Conferir as tabelas finais
SELECT * FROM nacao;

SELECT * FROM avatar;
