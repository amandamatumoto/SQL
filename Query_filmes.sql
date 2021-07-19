/*
Consultas simples de banco de dados sobre filmes.

Banco de dados:	bd_filmes
	lista de filmes
	categorias/g�neros
	classifica��o dos filmes

Comandos utilizados:
	SELECT
	FROM
	WHERE
	BETWEEN
	AND
	OR
	IS NULL
	LIKE
	TOP
	JOIN
	UNION
	INTERSECT
	EXCEPT
	CREATE VIEW
	ORDER BY
	GROUP BY
	HAVING
	CONCAT
	CASE WHEN
	STRING_AGG
*/


/*
	Analisando o banco de dados e suas tabelas: 
*/

-- Abrindo o banco de dados:

USE bd_filmes;

-- Informa��es gerais do banco de dados:

SELECT schema_name(t.schema_id) as schema_name,
       t.name as table_name,
       t.create_date,
       t.modify_date
FROM sys.tables t
ORDER BY schema_name,
         table_name;

/* 
Esta � uma tabela de fatos e dimens�es simples, no modelo estrela 
*/ 

-- Visualiza��o das tabelas:

SELECT *
FROM filmes;

/* 
Esta tabela possui informa��es sobre os filmes, t�tulo, sinopse, quantidade de votos, nota m�dia, 
	popularidade, link da imagem de capa e data de lan�amento
PK: id_filmes
Tabela dimens�o
*/

SELECT *
FROM filmes_genero;

/*  
Esta tabela serve de liga��o entre os filmes e seus respectivos g�neros
FKs: id_filmes, id_genero
Tabela fato
*/

SELECT *
FROM generos;
/*  
Esta tabela possui informa��es sobre o g�nero e sua descri��o
PK: id_genero
Tabela dimens�o
*/

/* 
	Criando consultas iniciais simples 
*/

-- Selecionando uma linha espec�fica: 
-- id_filme = 603 -- WHERE

SELECT id_filme, dsc_filme
FROM filmes
WHERE id_filme = 603;

-- Selecionando conjunto espec�fico: 
-- filmes com nota m�dia entre 80 e 90, com quantidade total de votos menores que 1000 -- BETWEEN

SELECT dsc_filme, num_nota_media, qtd_votos
FROM filmes
WHERE num_nota_media BETWEEN 80 AND 90
	AND qtd_votos < 1000;

-- Consultas com filtro de ordena��o:
-- Liste os filmes que est�o sem link de foto considerando tamb�m os registros sem dados -- IS NULL

SELECT dsc_filme, dsc_link_foto
FROM filmes
WHERE dsc_link_foto IS NULL;

-- Liste nome e data de lan�amento dos filmes que contenham a palavra 'Bela' -- LIKE

SELECT dsc_filme, dat_lancamento
FROM filmes
WHERE dsc_filme LIKE '%bela%';

-- Liste apenas os nomes dos filmes que contenham a palavra 'Bela' retirando os itens duplicados -- DISTINCT

SELECT DISTINCT dsc_filme
FROM filmes
WHERE dsc_filme LIKE '%bela%';

-- Liste a descri��o e a quantidade de votos dos filmes que tiveram mais de 1000 votos, ordenar pela quantidade de votos em ordem decrescente -- ORDER BY

SELECT dsc_filme, qtd_votos
FROM filmes
WHERE qtd_votos > 1000
ORDER BY qtd_votos DESC;

-- Liste os filmes da s�rie '007' com quantidade de votos acima de 3000 ou nota m�dia acima de 65 -- Hierarquia de opera��es

SELECT dsc_filme, qtd_votos, num_nota_media
FROM filmes
WHERE dsc_filme LIKE '%007%'
	AND (qtd_votos > 3000 
	OR num_nota_media > 65)

-- Liste nome e o �ndice de popularidade dos 5 filmes da s�rie '007' com maior popularidade -- TOP

SELECT TOP 5 dsc_filme, num_popularidade
FROM filmes
WHERE dsc_filme LIKE '%007%'
ORDER BY num_popularidade DESC;

-- Listar os filmes que s�o do g�nero Guerra ou do G�nero A��o -- JOIN e UNION

SELECT dsc_filme, dsc_genero
FROM filmes f
JOIN filmes_genero fg ON fg.id_filme = f.id_filme
JOIN generos g ON g.id_genero = fg.id_genero
WHERE g.dsc_genero = 'Guerra'

UNION

SELECT dsc_filme, dsc_genero
FROM filmes f
JOIN filmes_genero fg ON fg.id_filme = f.id_filme
JOIN generos g ON g.id_genero = fg.id_genero
WHERE g.dsc_genero = 'A��o';

-- Listar os filmes que s�o do g�nero Guerra e tamb�m do G�nero A��o -- INTERSECT

SELECT dsc_filme
FROM filmes f
JOIN filmes_genero fg ON fg.id_filme = f.id_filme
JOIN generos g ON g.id_genero = fg.id_genero
WHERE g.dsc_genero = 'Guerra'

INTERSECT

SELECT dsc_filme
FROM filmes f
JOIN filmes_genero fg ON fg.id_filme = f.id_filme
JOIN generos g ON g.id_genero = fg.id_genero
WHERE g.dsc_genero = 'A��o';

-- Listar os filmes que s�o do g�nero Guerra e n�o s�o do G�nero A��o -- EXCEPT

SELECT dsc_filme
FROM filmes f
JOIN filmes_genero fg ON fg.id_filme = f.id_filme
JOIN generos g ON g.id_genero = fg.id_genero
WHERE g.dsc_genero = 'Guerra'

EXCEPT

SELECT dsc_filme
FROM filmes f
JOIN filmes_genero fg ON fg.id_filme = f.id_filme
JOIN generos g ON g.id_genero = fg.id_genero
WHERE g.dsc_genero = 'A��o';


-- Utilizando o VIEW:

-- Criando uma view com o nome filmes_vw para listar todos os filmes com descri��o, g�nero e quantidade de votos 

CREATE VIEW filmes_vw AS 
	SELECT f.dsc_filme, g.dsc_genero, f.qtd_votos
	FROM filmes f
	JOIN filmes_genero fg ON fg.id_filme = f.id_filme
	JOIN generos g ON g.id_genero = fg.id_genero;

sp_help filmes_vw;

-- Utilizando a view criada para listar:

-- 3 g�neros mais votados:

SELECT TOP 3 dsc_genero, SUM(qtd_votos) as sum_votos
FROM filmes_vw
GROUP BY dsc_genero
ORDER BY 2 DESC;

-- 3 g�neros mais votados entre aqueles com menos de 600 mil votos: -- HAVING

SELECT TOP 3 dsc_genero, SUM(qtd_votos) as sum_votos
FROM filmes_vw
GROUP BY dsc_genero
HAVING SUM(qtd_votos) < 600000
ORDER BY 2 DESC;

-- Usando CAST:

SELECT filmes.*,
CAST(qtd_votos as float)
FROM filmes;


-- Usando CONCAT
-- Formatando o t�tulo dos filmes em conjunto com a sinopse

SELECT
	CONCAT(dsc_filme, ' - ', dsc_sinopse) AS T�tulo
FROM filmes

-- Usando CASE WHEN
-- Classificando a popularidade dos filmes em rela��o � quantidade de votos 

SELECT dsc_filme, qtd_votos,
	CASE 
		WHEN qtd_votos > 5000 THEN 'Popular'
		WHEN qtd_votos > 3000 AND qtd_votos <= 5000 THEN 'Regular'
		ELSE 'Impopular'
		END AS Popularidade
FROM filmes 


-- Usando STRING_AGG
-- Agrupando os g�neros dos filmes, o id dos g�neros e a quantidade.

SELECT f.dsc_filme, 
		STRING_AGG (g.dsc_genero, ', ')
			WITHIN GROUP ( ORDER BY f.id_filme) AS G�nero,
		STRING_AGG (fg.id_genero, ', ')
			WITHIN GROUP ( ORDER BY f.id_filme) AS id_g�nero,
		COUNT(fg.id_genero) AS qtd_g�nero
FROM filmes as f
INNER JOIN filmes_genero fg ON f.id_filme = fg.id_filme
INNER JOIN generos g ON fg.id_genero = g.id_genero
GROUP BY f.dsc_filme;
