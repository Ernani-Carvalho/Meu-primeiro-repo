-- =====================================================
-- Lista 7 - Exercício 3: Cadeia Evolutiva dos Pokémon
-- =====================================================

CREATE DATABASE IF NOT EXISTS sprint2;

USE sprint2;

-- Apaga as tabelas se já existirem (para poder rodar o script de novo)
-- A tabela pokemon é apagada primeiro porque ela referencia a tabela tipo
DROP TABLE IF EXISTS pokemon;

DROP TABLE IF EXISTS tipo;

-- =====================================================
-- CRIAÇÃO DAS TABELAS
-- =====================================================

-- A tabela tipo é criada primeiro porque a tabela pokemon referencia ela
CREATE TABLE tipo (
pkTipo INT PRIMARY KEY AUTO_INCREMENT,
nmTipo VARCHAR(45) NOT NULL
);

CREATE TABLE pokemon (
pkPokemon  INT PRIMARY KEY AUTO_INCREMENT,
nmPokemon  VARCHAR(45) NOT NULL,
nrPokedex  INT NOT NULL UNIQUE,
fkTipo     INT NOT NULL,
fkEvoluiDe INT,
FOREIGN KEY (fkTipo) REFERENCES tipo(pkTipo),
FOREIGN KEY (fkEvoluiDe) REFERENCES pokemon(pkPokemon)
);

-- =====================================================
-- COMANDOS
-- =====================================================

-- 1. Inserir os tipos
INSERT INTO tipo (nmTipo) VALUES
('Grama'),
('Fogo'),
('Água'),
('Venenoso'),
('Psíquico'),
('Normal'),
('Voador'),
('Elétrico');

-- 2. Inserir os treze Pokémon, cada um referenciando aquele do qual evolui
-- Tipos: 1 = Grama, 2 = Fogo, 3 = Água, 5 = Psíquico, 6 = Normal
INSERT INTO pokemon (nmPokemon, nrPokedex, fkTipo, fkEvoluiDe) VALUES
('Bulbasaur',  1,   1, NULL),
('Ivysaur',    2,   1, 1),
('Venusaur',   3,   1, 2),
('Charmander', 4,   2, NULL),
('Charmeleon', 5,   2, 4),
('Charizard',  6,   2, 5),
('Squirtle',   7,   3, NULL),
('Wartortle',  8,   3, 7),
('Blastoise',  9,   3, 8),
('Abra',       63,  5, NULL),
('Kadabra',    64,  5, 10),
('Alakazam',   65,  5, 11),
('Eevee',      133, 6, NULL);

-- 3. Nome, número da Pokédex e tipo de cada Pokémon
SELECT p.nmPokemon,
p.nrPokedex,
t.nmTipo
FROM pokemon p
JOIN tipo t ON p.fkTipo = t.pkTipo
ORDER BY p.nrPokedex;

-- 4. Todos os Pokémon e o Pokémon do qual evoluem (ou Forma Base)
SELECT p.nmPokemon,
p.nrPokedex,
CASE
WHEN p.fkEvoluiDe IS NULL THEN 'Forma Base'
ELSE ant.nmPokemon
END AS evoluiDe
FROM pokemon p
LEFT JOIN pokemon ant ON p.fkEvoluiDe = ant.pkPokemon
ORDER BY p.nrPokedex;

-- 5. Frase: [FORMA ANTERIOR] evolui para [POKÉMON]
SELECT CONCAT(ant.nmPokemon, ' evolui para ', p.nmPokemon) AS frase
FROM pokemon p
JOIN pokemon ant ON p.fkEvoluiDe = ant.pkPokemon
ORDER BY p.nrPokedex;

-- 6. Adicionar a coluna dsAtaqueEspecial
ALTER TABLE pokemon ADD COLUMN dsAtaqueEspecial VARCHAR(45);

-- 7. Preencher o ataque especial
UPDATE pokemon SET dsAtaqueEspecial = 'Frenesi Solar' WHERE pkPokemon = 3;

UPDATE pokemon SET dsAtaqueEspecial = 'Lança-Chamas' WHERE pkPokemon = 6;

UPDATE pokemon SET dsAtaqueEspecial = 'Hidro Bomba' WHERE pkPokemon = 9;

UPDATE pokemon SET dsAtaqueEspecial = 'Psíquico' WHERE pkPokemon = 12;

-- 8. Nome, número da Pokédex e Estágio na cadeia evolutiva
SELECT nmPokemon,
nrPokedex,
CASE
WHEN fkEvoluiDe IS NULL THEN 'Forma Base'
WHEN pkPokemon NOT IN (SELECT fkEvoluiDe FROM pokemon WHERE fkEvoluiDe IS NOT NULL) THEN 'Forma Final'
ELSE 'Forma Intermediária'
END AS Estágio
FROM pokemon
ORDER BY nrPokedex;

-- 9. Apenas as formas finais (nenhum outro Pokémon evolui delas)
SELECT p.nmPokemon,
p.nrPokedex,
t.nmTipo
FROM pokemon p
JOIN tipo t ON p.fkTipo = t.pkTipo
WHERE p.pkPokemon NOT IN (SELECT fkEvoluiDe FROM pokemon WHERE fkEvoluiDe IS NOT NULL)
ORDER BY p.nrPokedex;

-- 10. Remover o Pokémon de número 133 da Pokédex
DELETE FROM pokemon WHERE nrPokedex = 133;

-- Conferir a tabela final
SELECT * FROM pokemon;
