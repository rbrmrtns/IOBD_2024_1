DROP DATABASE IF EXISTS instapoble;

CREATE DATABASE instapoble;

\c instapoble; 

CREATE TABLE usuario (
    id serial primary key,
    nome character varying (100) not null,
    email character varying (100) unique not null,
    senha character varying (100) not null,
    data_nascimento date check (EXTRACT(YEAR FROM(AGE(data_nascimento))) >= 18)
);

INSERT INTO usuario (nome, email, senha, data_nascimento) VALUES 
('IGOR AVILA PEREIRA', 'igor.pereira@riogrande.ifrs.edu.br', md5('123'),'1987-01-20'),
('MÁRCIO JOSUÉ RAMOS TORRES', 'marcio.torres@riogrande.ifrs.edu.br', md5('456'),'1900-01-01');

CREATE TABLE conta (
    id serial primary key,
    nome_usuario text unique not null,
    data_hora_criacao timestamp default current_timestamp,
    -- isto eh comentario de linha            
    usuario_id integer references usuario (id)
);  
INSERT INTO conta (nome_usuario, usuario_id) VALUES
('igoravilapereira', 1),
('tobias', 1),
('marciotorres', 2),
('ifrsriogrande', 2);
/*
    isto eh comentario de bloco
*/

CREATE TABLE publicacao (
    id serial primary key,
    data_hora timestamp default current_timestamp,
    texto text,
    arquivo_principal text not null,
    latitude real,
    longitude real
);
INSERT INTO publicacao (arquivo_principal, texto) VALUES
('turma_iobd.jpeg', 'Pessoal de IOBD - Começando o ano Letivo com tudo #agoravai'),
('imagem_relogio.jpeg', 'Falei p turma que seria a saída 21:30 e me dei mal!'),
('tobias_de_chapeu.jpeg', 'Que bonitinho o gatinho snif snif!');

CREATE TABLE arquivo (
    id serial primary key,
    arquivo text not null,
    publicacao_id integer references publicacao (id)
);
INSERT INTO arquivo (arquivo, publicacao_id) VALUES
('tobias_de_chapeu2.jpeg', 3);

CREATE TABLE conta_publicacao (
    publicacao_id integer references publicacao (id),
    conta_id integer references conta (id),
    primary key (publicacao_id, conta_id)
);

INSERT INTO conta_publicacao (conta_id, publicacao_id) VALUES
(1,1), -- conta igoravilapereira recebe a 1a publicacao
(1,2), -- conta igoravilapereira recebe a 2a publicacao
(2,3); -- conta tobias (responsabilidade do usuario Igor Avila Pereira) recebe a 3a publicacao criada acima (tabela publicacao)

CREATE TABLE comentario (
    id serial primary key,
    texto text not null,
    data_hora timestamp default current_timestamp,
    publicacao_id integer references publicacao (id),
    conta_id integer references conta (id)    
);

INSERT INTO comentario (publicacao_id, conta_id, texto) values
(3, 3, 'que gatinho lindo!!! coração!');

INSERT INTO comentario (publicacao_id, conta_id, texto) values
(2, 3, 'que gatinho lindo!!! coração!');

INSERT INTO comentario (publicacao_id, conta_id, texto) values
(2, 3, 'que gasdfsdfsdfsdtinho lindo!!! coração!');

INSERT INTO comentario (publicacao_id, conta_id, texto) values
(2, 2, 'que gasdfsdfsdfsdtinho lindo!!! coração!');

-- instapoble=# select nome, nome_usuario from usuario inner join conta on (usuario.id = conta.usuario_id);

-- instapoble=# SELECT publicacao.texto, comentario.texto  FROM publicacao inner join comentario on (publicacao.id = comentario.publicacao_id);

-- instapoble=# SELECT publicacao.texto, comentario.texto  FROM publicacao left join comentario on (publicacao.id = comentario.publicacao_id) where comentario.publicacao_id is null;

-- instapoble=# SELECT * FROM publicacao where id not in (select publicacao_id from comentario);

-- instapoble=# SELECT texto FROM publicacao except select publicacao.texto from publicacao inner join comentario on (publicacao.id = comentario.publicacao_id);

-- instapoble=# select usuario.nome, count(*) from usuario inner join conta on (usuario.id = conta.usuario_id) where usuario.nome ILIKE 'I%' group by usuario.id having count(*) >= 2;

-- instapoble=# Select nome, count(*) from usuario inner join conta on (usuario.id = conta.usuario_id) inner join conta_publicacao on (conta.id = conta_publicacao.conta_id) group by usuario.id;

-- instapoble=# SELECT texto, arquivo FROM publicacao left join arquivo on (publicacao.id = arquivo.publicacao_id) where arquivo.publicacao_id is null;

-- instapoble=# select nome_usuario, count(*) from conta inner join comentario on (conta.id = comentario.conta_id) group by conta.id having count(*) = (select count(*) from conta inner join comentario on (conta.id = comentario.conta_id) group by conta.id order by count(*) desc limit 1);

-- instapoble=# SELECT conta.id, usuario.nome, conta.nome_usuario, conta.data_hora_criacao FROM usuario inner join conta on (usuario.id = conta.usuario_id) ORDER BY conta.id DESC LIMIT 1;