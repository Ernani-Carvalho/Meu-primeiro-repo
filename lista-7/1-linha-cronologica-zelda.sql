-- =====================================================
-- Lista 7 - Exercício 1: Linha Cronológica de Zelda
-- =====================================================

CREATE DATABASE IF NOT EXISTS sprint2;
USE sprint2;

-- Apaga a tabela se ela já existir (para poder rodar o script de novo)
DROP TABLE IF EXISTS jogoZelda;

-- Criar a tabela
CREATE TABLE jogoZelda (pkJogo INT PRIMARY KEY AUTO_INCREMENT, nmJogo VARCHAR(45) NOT NULL, anoLançamento YEAR NOT NULL, fkJogoAnterior INT UNIQUE, FOREIGN KEY (fkJogoAnterior) REFERENCES jogoZelda(pkJogo));

-- 1. Inserir os doze jogos, cada um referenciando o anterior
INSERT INTO jogoZelda (nmJogo, anoLançamento, fkJogoAnterior) VALUES ('The Legend of Zelda', 1986, NULL), ('Zelda II: The Adventure of Link', 1987, 1), ('A Link to the Past', 1991, 2), ('Link''s Awakening', 1993, 3), ('Ocarina of Time', 1998, 4), ('Majora''s Mask', 2000, 5), ('The Wind Waker', 2002, 6), ('Twilight Princess', 2006, 7), ('Skyward Sword', 2011, 8), ('A Link Between Worlds', 2013, 9), ('Breath of the Wild', 2017, 10), ('Tears of the Kingdom', 2023, 11);

-- 2. Cada jogo ao lado do jogo que o antecede
SELECT j.nmJogo AS jogo, a.nmJogo AS antecessor FROM jogoZelda j JOIN jogoZelda a ON j.fkJogoAnterior = a.pkJogo;

-- 3. Título, ano e Período (era da franquia), do mais antigo para o mais recente
SELECT nmJogo, anoLançamento, CASE WHEN anoLançamento < 1995 THEN 'Era Clássica' WHEN anoLançamento BETWEEN 1995 AND 2010 THEN 'Era Moderna' ELSE 'Era Contemporânea' END AS Período FROM jogoZelda ORDER BY anoLançamento;

-- 4. Adicionar a coluna nmConsole
ALTER TABLE jogoZelda ADD COLUMN nmConsole VARCHAR(45);

-- 5. Preencher o console de cada jogo
UPDATE jogoZelda SET nmConsole = 'NES' WHERE pkJogo IN (1, 2);
UPDATE jogoZelda SET nmConsole = 'SNES' WHERE pkJogo = 3;
UPDATE jogoZelda SET nmConsole = 'Game Boy' WHERE pkJogo = 4;
UPDATE jogoZelda SET nmConsole = 'Nintendo 64' WHERE pkJogo IN (5, 6);
UPDATE jogoZelda SET nmConsole = 'GameCube' WHERE pkJogo = 7;
UPDATE jogoZelda SET nmConsole = 'Wii' WHERE pkJogo IN (8, 9);
UPDATE jogoZelda SET nmConsole = 'Nintendo 3DS' WHERE pkJogo = 10;
UPDATE jogoZelda SET nmConsole = 'Nintendo Switch' WHERE pkJogo IN (11, 12);

-- 6. Consoles e jogos, do mais recente para o mais antigo
SELECT nmConsole, nmJogo FROM jogoZelda ORDER BY anoLançamento DESC;

-- 7. Frase: [JOGO] é o sucessor de [ANTECESSOR]
SELECT CONCAT(j.nmJogo, ' é o sucessor de ', a.nmJogo) AS frase FROM jogoZelda j JOIN jogoZelda a ON j.fkJogoAnterior = a.pkJogo;

-- 8. Jogos sem antecessor
SELECT nmJogo, anoLançamento FROM jogoZelda WHERE fkJogoAnterior IS NULL;

-- 9. Remover o jogo mais recente (nenhum outro jogo o referencia como antecessor)
-- Conferir qual é: o resultado deve ser Tears of the Kingdom (pkJogo = 12)
SELECT * FROM jogoZelda WHERE pkJogo NOT IN (SELECT fkJogoAnterior FROM jogoZelda WHERE fkJogoAnterior IS NOT NULL);
DELETE FROM jogoZelda WHERE pkJogo = 12;

-- Conferir a tabela final
SELECT * FROM jogoZelda;
