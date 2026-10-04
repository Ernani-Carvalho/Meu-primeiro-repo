-- =====================================================
-- EXTRA - Exercício 1: Biblioteca e Livros
-- =====================================================

CREATE DATABASE IF NOT EXISTS sprint2;

USE sprint2;

-- Apaga as tabelas se já existirem (para poder rodar o script de novo)
-- A tabela livro é apagada primeiro porque ela referencia a tabela autor
DROP TABLE IF EXISTS livro;

DROP TABLE IF EXISTS autor;

-- =====================================================
-- MODELAGEM E CRIAÇÃO
-- =====================================================

-- A tabela autor é criada primeiro porque a tabela livro referencia ela
CREATE TABLE autor (
pkAutor       INT PRIMARY KEY AUTO_INCREMENT,
nmAutor       VARCHAR(45) NOT NULL,
nacionalidade VARCHAR(45) NOT NULL,
dtNascimento  DATE
);

CREATE TABLE livro (
pkLivro       INT PRIMARY KEY AUTO_INCREMENT,
titulo        VARCHAR(100) NOT NULL,
qtdPaginas    INT NOT NULL,
anoPublicacao INT NOT NULL,
preco         DECIMAL(6,2) NOT NULL,
situacao      VARCHAR(20) NOT NULL DEFAULT 'Disponível',
fkAutor       INT NOT NULL,
CONSTRAINT chkPaginas CHECK (qtdPaginas > 0),
CONSTRAINT chkSituacao CHECK (situacao IN ('Disponível', 'Emprestado', 'Reservado')),
FOREIGN KEY (fkAutor) REFERENCES autor(pkAutor)
);

-- Inserir os autores
INSERT INTO autor (nmAutor, nacionalidade, dtNascimento) VALUES
('Machado de Assis',       'Brasileira', '1839-06-21'),
('Jorge Amado',            'Brasileira', '1912-08-10'),
('J. K. Rowling',          'Britânica',  '1965-07-31'),
('George Orwell',          'Britânica',  '1903-06-25'),
('Gabriel García Márquez', 'Colombiana', '1927-03-06');

-- Inserir os livros
-- Autores: 1 = Machado de Assis, 2 = Jorge Amado, 3 = J. K. Rowling, 4 = George Orwell, 5 = Gabriel García Márquez
INSERT INTO livro (titulo, qtdPaginas, anoPublicacao, preco, situacao, fkAutor) VALUES
('Dom Casmurro',                     256, 1899, 29.90, 'Disponível', 1),
('Memórias Póstumas de Brás Cubas',  208, 1881, 34.90, 'Emprestado', 1),
('O Alienista',                      96,  1882, 19.90, 'Disponível', 1),
('Capitães da Areia',                280, 1937, 39.90, 'Disponível', 2),
('Harry Potter e a Pedra Filosofal', 264, 1997, 49.90, 'Emprestado', 3),
('Harry Potter e o Cálice de Fogo',  536, 2000, 69.90, 'Disponível', 3),
('1984',                             416, 1949, 44.90, 'Reservado',  4),
('A Revolução dos Bichos',           152, 1945, 24.90, 'Disponível', 4),
('Cem Anos de Solidão',              448, 1967, 59.90, 'Disponível', 5);

-- =====================================================
-- CONSULTAS E MANIPULAÇÃO
-- =====================================================

-- a) Todos os dados dos livros
SELECT * FROM livro;

-- b) Título, ano de publicação e autor
SELECT l.titulo,
l.anoPublicacao,
a.nmAutor
FROM livro l
JOIN autor a ON l.fkAutor = a.pkAutor;

-- c) Livros publicados após 1950
SELECT l.titulo,
l.anoPublicacao,
a.nmAutor
FROM livro l
JOIN autor a ON l.fkAutor = a.pkAutor
WHERE l.anoPublicacao > 1950;

-- d) Livros de Machado de Assis
SELECT l.titulo,
l.anoPublicacao
FROM livro l
JOIN autor a ON l.fkAutor = a.pkAutor
WHERE a.nmAutor = 'Machado de Assis';

-- e) Livros com preço entre R$ 30,00 e R$ 50,00
SELECT titulo,
preco
FROM livro
WHERE preco BETWEEN 30 AND 50;

-- f) Título, autor, páginas e classificação
SELECT l.titulo,
a.nmAutor,
l.qtdPaginas,
CASE
WHEN l.qtdPaginas <= 200 THEN 'Curto'
WHEN l.qtdPaginas <= 400 THEN 'Médio'
ELSE 'Longo'
END AS classificacao
FROM livro l
JOIN autor a ON l.fkAutor = a.pkAutor;

-- g) Atualizar o preço de Dom Casmurro
UPDATE livro SET preco = 32.90 WHERE pkLivro = 1;

-- h) Excluir o livro O Alienista
DELETE FROM livro WHERE pkLivro = 3;

-- i) Título, autor e ano, do mais recente para o mais antigo
SELECT l.titulo,
a.nmAutor,
l.anoPublicacao
FROM livro l
JOIN autor a ON l.fkAutor = a.pkAutor
ORDER BY l.anoPublicacao DESC;
