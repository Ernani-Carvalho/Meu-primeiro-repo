-- =====================================================
-- Script completo: Funcionário/Área e Usuário/Email
-- =====================================================

-- Cria um banco novo só para esta atividade
DROP DATABASE IF EXISTS atividade_bd;
CREATE DATABASE atividade_bd;
USE atividade_bd;

-- =====================================================
-- ATIVIDADE 1: FUNCIONÁRIO E ÁREA
-- =====================================================

-- Tabela area
CREATE TABLE area (id INT PRIMARY KEY AUTO_INCREMENT, nome VARCHAR(100));

-- Tabela funcionario
CREATE TABLE funcionario (id INT PRIMARY KEY AUTO_INCREMENT, nome VARCHAR(100), area_id INT, supervisor_id INT, FOREIGN KEY (area_id) REFERENCES area(id), FOREIGN KEY (supervisor_id) REFERENCES funcionario(id));

-- Inserir as áreas
INSERT INTO area (nome) VALUES ('Marketing'), ('Financeiro'), ('TI');

-- Inserir os funcionários
INSERT INTO funcionario (id, nome, area_id, supervisor_id) VALUES (1, 'Carla', 3, 1), (2, 'Diego', 3, 1), (3, 'Lia', 3, 1), (4, 'Ana', 1, 1), (5, 'Bruno', 1, 4), (6, 'Paulo', 2, 1), (7, 'Rita', 2, 6);

-- Cada funcionário, sua área e o nome de seu supervisor
SELECT f.nome AS funcionario, a.nome AS area, s.nome AS supervisor FROM funcionario f JOIN area a ON f.area_id = a.id JOIN funcionario s ON f.supervisor_id = s.id;

-- Funcionários cujo supervisor é Ana
SELECT * FROM funcionario WHERE supervisor_id = 4;

-- Cada funcionário, sua área e o papel (Chefia ou Equipe)
SELECT f.nome, a.nome AS area, CASE WHEN f.id IN (SELECT supervisor_id FROM funcionario WHERE supervisor_id <> id) THEN 'Chefia' ELSE 'Equipe' END AS papel FROM funcionario f JOIN area a ON f.area_id = a.id;

-- =====================================================
-- ATIVIDADE 2: USUÁRIO E EMAIL
-- =====================================================

-- Tabela usuario
CREATE TABLE usuario (id INT PRIMARY KEY AUTO_INCREMENT, nome VARCHAR(100), gerente_id INT, FOREIGN KEY (gerente_id) REFERENCES usuario(id));

-- Tabela email
CREATE TABLE email (id INT PRIMARY KEY AUTO_INCREMENT, usuario_id INT, endereco VARCHAR(150), tipo VARCHAR(50), FOREIGN KEY (usuario_id) REFERENCES usuario(id));

-- Inserir os usuários
INSERT INTO usuario (nome, gerente_id) VALUES ('Helena', 1), ('Ana', 1), ('Bruno', 1), ('Caio', 2), ('Duda', 2), ('Eva', 3);

-- Inserir os emails
INSERT INTO email (id, usuario_id, endereco, tipo) VALUES (1, 1, 'helena@empresa.com', 'corporativo'), (2, 1, 'helena@gmail.com', 'pessoal'), (3, 2, 'ana@empresa.com', 'corporativo'), (4, 2, 'ana@gmail.com', 'pessoal'), (5, 3, 'bruno@empresa.com', 'corporativo'), (6, 4, 'caio@empresa.com', 'corporativo'), (7, 5, 'duda@empresa.com', 'corporativo'), (8, 5, 'duda@gmail.com', 'pessoal'), (9, 6, 'eva@empresa.com', 'corporativo');

-- Cada usuário e o nome do seu gerente
SELECT u.nome AS usuario, g.nome AS gerente FROM usuario u JOIN usuario g ON u.gerente_id = g.id;

-- Usuários cujo gerente é Ana, apenas com emails corporativos
SELECT u.nome, e.endereco FROM usuario u JOIN email e ON e.usuario_id = u.id WHERE u.gerente_id = 2 AND e.tipo = 'corporativo';

-- Cada usuário, seu gerente, nivel e perfil_emails
SELECT u.nome AS usuario, g.nome AS gerente, CASE WHEN u.id = u.gerente_id THEN 'Topo' ELSE 'Equipe' END AS nivel, CASE WHEN u.id IN (SELECT e1.usuario_id FROM email e1 JOIN email e2 ON e1.usuario_id = e2.usuario_id WHERE e1.id <> e2.id) THEN 'Multiplos Emails' ELSE 'Email Único' END AS perfil_emails FROM usuario u JOIN usuario g ON u.gerente_id = g.id;
