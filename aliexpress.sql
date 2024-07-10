DROP DATABASE IF EXISTS aliexpress;

CREATE DATABASE aliexpress;

\c aliexpress;

-- exemplo de schemas
CREATE SCHEMA localizacao;
SET search_path TO public, localizacao;

-- exemplo de tabelas criadas em outro schema - além do public.
CREATE TABLE localizacao.estado (
    id serial primary key,
    nome text not null,
    sigla character(2) not null
);
INSERT INTO localizacao.estado (nome, sigla) VALUES ('RIO GRANDE DO SUL', 'RS');

CREATE TABLE localizacao.cidade (
    id serial primary key,
    nome text not null,
    estado_id integer references localizacao.estado (id)
);
-- exemplo de insert
INSERT INTO localizacao.cidade (nome, estado_id) VALUES ('RIO GRANDE', 1);

CREATE TABLE fornecedor (
    cnpj character(14) primary key,
    razao_social character varying (200) not null,
    endereco text,
    cidade_id integer references localizacao.cidade (id)
);
INSERT INTO fornecedor (cnpj, razao_social, endereco, cidade_id) VALUES
('97276163000133', 'FIFINE CORPORATION', 'ALFREDO HUCH 134', 1),
('97276163000132', 'M-VAVE GUITARS PRODUCTS', 'LAR GAÚCHO', 1);

INSERT INTO fornecedor (cnpj, razao_social, endereco) VALUES
('97276163000131', 'WHAAH Pickups', 'PARQUE SÃO PEDRO');

CREATE TABLE cliente (
    id serial primary key,
    nome character varying(100) not null,
    bairro text,
    rua text,
    complemento text,
    nro text,
    cep character(8),
    cidade_id integer references localizacao.cidade (id)
);
INSERT INTO cliente (nome, bairro, rua, complemento, nro, cep, cidade_id) VALUES
('IGOR PEREIRA', 'TREVO', 'RUA DO TREVO', NULL, '201', '96202188', 1),
('RAFAEL BETITO', 'PARQUE MARINHA', 'RUA DO MARINHA', NULL, '134', '96202100', 1);

CREATE TABLE nota  (
    id serial primary key,
--    exemplo de valor default (padrão)
    data_hora timestamp default current_timestamp,
    tipo_pagamento character varying(100) check(tipo_pagamento in ('DINHEIRO', 'PIX', 'CARTÃO', 'BOLETO')),
    impostos money,
    cliente_id integer references cliente (id)
);
INSERT INTO nota (tipo_pagamento, cliente_id) VALUES 
('PIX', 1);

CREATE TABLE produto (
    id serial primary key,
--    exemplo de restrição not null (não-nulo)
    descricao text not null,
    estoque integer check(estoque >= 0),
    valor money check(cast(valor as numeric(8,2)) >= 0),
    cnpj_fornecedor character(14) references fornecedor (cnpj)
);
INSERT INTO produto (descricao, estoque, valor, cnpj_fornecedor) VALUES
('MICROFONE KM688', 100, 150.00, '97276163000133'),
('SUPORTE PARA MICROFONES', 200, 250, '97276163000133');

CREATE TABLE item (
-- exemplo de fk's
    nota_id integer references nota (id),
    produto_id integer references produto (id),
-- exemplo de checagem
    qtde integer check (qtde > 0),
    preco_unitario_pago money check(cast(preco_unitario_pago as numeric(8,2)) >= 0),
--    exemplo de pk composta
    primary key (nota_id, produto_id)
);
INSERT INTO item (nota_id, produto_id, qtde, preco_unitario_pago) VALUES
(1,1,1,150.00);

-- exemplo de inner join. Aqui envolve 2 tabelas: a tabela de fornecedor, e a tabela de cidade.
-- aliexpress=# SELECT fornecedor.*, cidade.nome FROM fornecedor inner join cidade on (fornecedor.cidade_id = cidade.id);

-- exemplo de group by
-- aliexpress=# SELECT tipo_pagamento, count(*) FROM nota group by tipo_pagamento;

-- criação da view
-- aliexpress=# CREATE VIEW fornecedor_cidade AS SELECT fornecedor.*, cidade.nome FROM fornecedor inner join cidade on (fornecedor.cidade_id = cidade.id);
-- uso da view
--aliexpress=# select * from fornecedor_cidade;

-- exemplo de exclusão de uma view
--DROP VIEW fornecedor_cidade;

-- criação de uma view que lista fornecedores e suas cidades. Neste caso, com left, fornecedores sem cidade cadastrada também irão aparecer
--CREATE VIEW fornecedor_cidade AS SELECT fornecedor.*, cidade.nome FROM fornecedor left join cidade on (fornecedor.cidade_id = cidade.id);



--Exercícios Lista 3

--Quais produtos estão sem estoque?

SELECT * FROM produto WHERE estoque = 0;

-- Qual produto mais vendido no último mês?

SELECT * FROM produto WHERE id IN (SELECT produto_id FROM item JOIN nota ON nota.id = item.nota_id WHERE DATE_TRUNC('MONTH', nota.data_hora)::DATE = DATE_TRUNC('MONTH', CURRENT_TIMESTAMP - INTERVAL '1 month')::DATE GROUP BY produto_id ORDER BY SUM(qtde) DESC LIMIT 1);

-- Qual o produto mais vendido?

SELECT * FROM produto WHERE id IN (SELECT produto_id FROM item JOIN nota ON nota.id = item.nota_id GROUP BY produto_id ORDER BY SUM(qtde) DESC LIMIT 1); 

-- Quantidade de pedidos por cliente?

SELECT cliente.id, cliente.nome, COUNT(*) as quant_pedidos FROM cliente JOIN nota ON nota.cliente_id = cliente.id GROUP BY cliente.id;

-- Média de preço dos produtos

SELECT ROUND(AVG(valor::NUMERIC)) AS media_precos FROM produto;

-- Somente produtos comprados entre um determinado intervalo de datas

SELECT DISTINCT produto.id, produto.descricao FROM produto JOIN item ON item.produto_id = produto.id JOIN nota ON nota.id = item.nota_id WHERE DATE(nota.data_hora) BETWEEN DATE(CURRENT_TIMESTAMP) - INTERVAL '1 month' AND DATE(CURRENT_TIMESTAMP);

-- Quais clientes fizeram mais pedidos?

SELECT cliente.*, COUNT(*) AS quant_pedidos FROM cliente JOIN nota ON nota.cliente_id = cliente.id GROUP BY cliente.id HAVING COUNT(*) = (SELECT COUNT(*) AS pedidos FROM nota GROUP BY cliente_id ORDER BY pedidos DESC LIMIT 1);

-- Qual pedido que solicitou a maior quantide de itens?

SELECT *, SUM(qtde) AS quant_itens FROM item GROUP BY nota_id, produto_id HAVING SUM(qtde) = (SELECT SUM(qtde) FROM item GROUP BY nota_id, produto_id ORDER BY SUM(qtde) DESC LIMIT 1);