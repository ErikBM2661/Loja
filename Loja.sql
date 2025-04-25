CREATE SEQUENCE seq_pessoa
START WITH 1
INCREMENT BY 1;
GO

CREATE TABLE Usuario (
    id_usuario INT IDENTITY(1,1) PRIMARY KEY,
    nome VARCHAR(100),
    login VARCHAR(50) UNIQUE,
    senha VARCHAR(50)
);

CREATE TABLE Pessoa (
    id_pessoa INT PRIMARY KEY DEFAULT NEXT VALUE FOR seq_pessoa,
    nome VARCHAR(100),
    endereco VARCHAR(200),
    telefone VARCHAR(20),
    email VARCHAR(100),
    cpf VARCHAR(14),
    cnpj VARCHAR(18)
);

CREATE TABLE Produto (
    id_produto INT IDENTITY(1,1) PRIMARY KEY,
    nome VARCHAR(100),
    quantidade INT,
    preco_venda DECIMAL(10,2)
);

CREATE TABLE Compra (
    id_compra INT IDENTITY(1,1) PRIMARY KEY,
    id_usuario INT,
    id_produto INT,
    id_fornecedor INT,
    quantidade INT,
    preco_unitario DECIMAL(10,2),
    data DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (id_usuario) REFERENCES Usuario(id_usuario),
    FOREIGN KEY (id_produto) REFERENCES Produto(id_produto),
    FOREIGN KEY (id_fornecedor) REFERENCES Pessoa(id_pessoa)
);

CREATE TABLE Venda (
    id_venda INT IDENTITY(1,1) PRIMARY KEY,
    id_usuario INT,
    id_produto INT,
    id_cliente INT,
    quantidade INT,
    data DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (id_usuario) REFERENCES Usuario(id_usuario),
    FOREIGN KEY (id_produto) REFERENCES Produto(id_produto),
    FOREIGN KEY (id_cliente) REFERENCES Pessoa(id_pessoa)
);

INSERT INTO Usuario (nome, login, senha) VALUES
('1', 'op1', 'op1'),
('2', 'op2', 'op2');

INSERT INTO Produto (nome, quantidade, preco_venda) VALUES
('Mouse', 100, 50.00),
('Teclado', 200, 80.00),
('Monitor', 50, 600.00);

DECLARE @idPF1 INT = NEXT VALUE FOR seq_pessoa;
INSERT INTO Pessoa (id_pessoa, nome, endereco, telefone, email, cpf) VALUES
(@idPF1, 'Roland', 'Distrito 7, 100', '99999999999', 'roland@gmail.com', '123.456.789-00');

DECLARE @idPJ1 INT = NEXT VALUE FOR seq_pessoa;
INSERT INTO Pessoa (id_pessoa, nome, endereco, telefone, email, cnpj) VALUES
(@idPJ1, 'TimeTrack Corporation', 'Distrito 20', '1133334444', 'tcorp@wing.com', '12.345.678/0001-99');

INSERT INTO Compra (id_usuario, id_produto, id_fornecedor, quantidade, preco_unitario) 
VALUES (1, 1, @idPJ1, 10, 40.00);

INSERT INTO Venda (id_usuario, id_produto, id_cliente, quantidade) 
VALUES (2, 1, @idPF1, 5);

SELECT * FROM Pessoa WHERE cpf IS NOT NULL;

SELECT * FROM Pessoa WHERE cnpj IS NOT NULL;

SELECT c.id_compra, p.nome AS produto, f.nome AS fornecedor, c.quantidade, 
       c.preco_unitario, (c.quantidade * c.preco_unitario) AS valor_total
FROM Compra c
JOIN Produto p ON c.id_produto = p.id_produto
JOIN Pessoa f ON c.id_fornecedor = f.id_pessoa;

SELECT v.id_venda, p.nome AS produto, c.nome AS comprador, v.quantidade, 
       p.preco_venda AS preco_unitario, (v.quantidade * p.preco_venda) AS valor_total
FROM Venda v
JOIN Produto p ON v.id_produto = p.id_produto
JOIN Pessoa c ON v.id_cliente = c.id_pessoa;

SELECT p.nome, SUM(c.quantidade * c.preco_unitario) AS total_entrada
FROM Compra c
JOIN Produto p ON c.id_produto = p.id_produto
GROUP BY p.nome;

SELECT p.nome, SUM(v.quantidade * p.preco_venda) AS total_saida
FROM Venda v
JOIN Produto p ON v.id_produto = p.id_produto
GROUP BY p.nome;

SELECT u.id_usuario, u.nome
FROM Usuario u
WHERE u.id_usuario NOT IN (SELECT DISTINCT id_usuario FROM Compra);

SELECT u.nome, SUM(c.quantidade * c.preco_unitario) AS total_comprado
FROM Compra c
JOIN Usuario u ON c.id_usuario = u.id_usuario
GROUP BY u.nome;

SELECT u.nome, SUM(v.quantidade * p.preco_venda) AS total_vendido
FROM Venda v
JOIN Usuario u ON v.id_usuario = u.id_usuario
JOIN Produto p ON v.id_produto = p.id_produto
GROUP BY u.nome;

SELECT p.nome, 
       CAST(SUM(v.quantidade * p.preco_venda) AS FLOAT) / SUM(v.quantidade) AS media_ponderada
FROM Venda v
JOIN Produto p ON v.id_produto = p.id_produto
GROUP BY p.nome;
