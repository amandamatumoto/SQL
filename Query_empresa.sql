/*
Consultas simples de banco de dados sobre uma empresa fict�cia.

Banco de dados: bd_empresa

Comandos utilizados:
	INNER JOIN
	OUTER JOIN
	LEFT JOIN
	RTRIM
	CONVERT
	MONTH
	DAY
	YEAR
	GETDATE
	NOT IN
	NOT EXISTS
	COUNT
	AVG
	SUM
	WITH
	CASE WHEN
	COALESCE 
	CAST
	FULL OUTER JOIN

*/

/*
	Analisando o banco de dados e suas tabelas: 
*/

-- Abrindo o banco de dados:

USE bd_empresa

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
FROM alocacao;
-- Esta tabela relaciona o funcion�rio ao projeto e a quantidade de horas aplicadas nele
-- FK: num_matricula, cod_projeto

SELECT *
FROM departamento;
-- Esta tabela relaciona o departamento ao gerente, incluindo a data de in�cio de ger�ncia
-- PK: cod_depto

SELECT *
FROM departamento_local;
-- Esta tabela relaciona o departamento ao seu local
-- FK: cod_dpto

SELECT *
FROM dependente;
-- Esta tabela relaciona o funcion�rio aos seus dependentes
-- FK: num_matricula

SELECT *
FROM empregado;
-- Esta tabela cont�m a lista de funcion�rios e suas informa��es
-- PK: num_matricula
-- FK: cod_depto

SELECT *
FROM projeto;
-- Esta tabela cont�m informa��es sobre os projetos e relaciona ao seu departamento
-- PK: cod_projeto
-- FK: cod_depto


/* 
	Criando consultas iniciais simples 
*/

-- Listando os projetos que acontecem em BH -- WHERE

SELECT *
FROM projeto
WHERE nom_local = 'BH';

-- Listando todos os empregados do sexo masculino que moram em MG -- AND

SELECT *
FROM empregado
WHERE sex_empregado = 'M' AND
		sig_uf = 'MG';

-- Listando o n�mero de matr�cula e nome do empregados e nome e parentesco de todos os dependentes -- INNER JOIN

SELECT e.num_matricula, e.nom_empregado, d.nom_dependente, d.dsc_parentesco
FROM empregado e
JOIN dependente d ON d.num_matricula = e.num_matricula;

-- Listando o nome dos departamentos com n�mero de matr�cula e nome de todos os funcion�rio. 
-- Ordenando o resultado por departamento e nome do empregado.

SELECT nom_depto, num_matricula, nom_empregado
FROM departamento d
JOIN empregado e ON d.cod_depto = e.cod_depto
ORDER BY nom_depto, nom_empregado;


-- Listando nome dos departamentos com n�mero de matr�cula e nome do gerente respons�vel.
-- Para cada departamento um dos funcion�rios tem a fun��o de ger�ncia.

SELECT nom_depto, num_matricula, d.num_matricula_gerente AS gerente
FROM departamento d
JOIN empregado e ON e.num_matricula = d.num_matricula_gerente

-- Listando o n�mero de matr�cula e nome dos supervisores e n�mero de matr�cula e nome dos funcion�rios sob sua supervis�o. 
-- Ordenando os supervisores e empregados em ordem alfab�tica 

SELECT sup.num_matricula_supervisor as matricula_supervisor,
	sup.nom_empregado as nome_supervisor,
	e.num_matricula as matricula_empregado,
	e.nom_empregado as nome_empregado
FROM empregado e
JOIN empregado sup ON sup.num_matricula = e.num_matricula_supervisor
ORDER BY 2, 4;

-- Listando os funcion�rios dos projetos de BH com o total de horas alocado.  
-- Exibindo nome e local do projeto, n�mero de matr�cula e nome do empregado e o total de horas alocado.

SELECT p.nom_projeto, p.nom_local, e.num_matricula, e.nom_empregado, a.num_horas
FROM empregado e
JOIN alocacao a ON e.num_matricula = a.num_matricula
JOIN projeto p ON p.cod_depto = a.cod_projeto
WHERE p.nom_local = 'BH';

-- Consultas juntando tabelas com OUTER JOIN

-- Listando o n�mero de matr�cula e nome dos empregados e nome e parentesco dos seus dependentes. 
-- Considerando tamb�m os funcion�rios que n�o tem dependentes. -- LEFT JOIN

SELECT e.num_matricula, e.nom_empregado, d.nom_dependente, d.dsc_parentesco
FROM empregado e
LEFT JOIN dependente d ON e.num_matricula = d.num_matricula;

-- Listando o n�mero de matr�cula e nome dos empregados que n�o tem dependentes cadastrados.

SELECT e.num_matricula, e.nom_empregado, d.nom_dependente
FROM empregado e
LEFT JOIN dependente d ON e.num_matricula = d.num_matricula
WHERE d.nom_dependente IS NULL

-- Listar os nomes dos projetos, os locais de execu��o, o departamento, e os gerentes respons�veis.
-- Considerando tamb�m os departamentos sem projeto e sem gerente.

SELECT p.nom_projeto, p.nom_local, d.cod_depto, d.num_matricula_gerente
	FROM empregado e
LEFT JOIN departamento d ON d.num_matricula_gerente = e. num_matricula
LEFT JOIN projeto p ON p.cod_depto = d.cod_depto

-- Formatando o resultado - RTRIM, CONVERT

-- Listando o n�mero de matr�cula e nome dos empregados e seus dependentes, 
-- exibindo a coluna 'dependentes' com nome do dependente e o parentesco entre par�ntesis. Exemplo: Zezinho (filho)

SELECT e.num_matricula, e.nom_empregado, 
	d.nom_dependente + ' (' + RTRIM (d.dsc_parentesco) + ')' as Dependentes
FROM empregado e
JOIN dependente d ON e.num_matricula = d.num_matricula;

-- Listando os departamentos, com seu respectivos gerentes e a data de in�cio da ger�ncia no formato dia-m�s-ano

SELECT d.nom_depto, e.nom_empregado, 
	CONVERT (varchar(10), d.dat_inicio_gerente, 105) AS inicio_gerencia
FROM departamento d
JOIN empregado e ON e.num_matricula = d.num_matricula_gerente;

-- Liste os empregados e horas de aloca��o em cada projeto no formato abaixo:
-- Nome: Rodrigo Moreira Projeto: Migra��o para SQL 2005 - 10 horas
-- Considere todos os funcion�rios, incluindo os que n�o tem projeto

SELECT 'Nome: ' + e.nom_empregado +
		' Projeto: ' + ISNULL (nom_projeto, '-') + ' -' +
		CONVERT (varchar(2), ISNULL(num_horas,0)) + ' horas' AS Alocacao
	FROM empregado e
	JOIN alocacao a ON a.num_matricula = e.num_matricula
	JOIN projeto p ON p.cod_projeto = a.cod_projeto;

-- Trabalhando com data e hora:

-- Gerando a lista de aniversariantes da empresa com m�s, dia e nome do empregado ordem cronol�gica

SELECT 	MONTH(dat_nascimento) AS M�s,
		DAY(dat_nascimento) AS Dia,
		nom_empregado
	FROM empregado
	ORDER BY 1, 2;

-- Listando os departamentos e seus gerentes com tempo de ger�ncia em anos ordenando pelo mais antigo
-- GETDATE

SELECT nom_depto, nom_empregado AS gerente,
	YEAR(getdate()) - YEAR(d.dat_inicio_gerente) tempo_gerencia
	FROM empregado e
	JOIN departamento d ON e.num_matricula = d.num_matricula_gerente
	ORDER BY 3 DESC

-- DATEDIFF

SELECT nom_depto, nom_empregado AS gerente,
	  DATEDIFF(year, dat_inicio_gerente, getdate())tempo_gerencia
	FROM empregado e
	JOIN departamento d ON e.num_matricula = d.num_matricula_gerente
	ORDER BY 3 DESC;

-- Listando nome dos departamentos com nomes dos empregados e a quantidade de dependentes, se houver.
-- COUNT

SELECT d.nom_depto, e.nom_empregado, COUNT(dp.num_matricula) AS qtd_dependentes
FROM empregado e 
JOIN departamento d ON e.cod_depto = d.cod_depto
LEFT JOIN dependente dp ON dp.num_matricula = e.num_matricula
GROUP BY nom_depto, nom_empregado
ORDER BY nom_depto, nom_empregado;

-- Listando somente os locais e a quantidade de projetos onde houver mais de 2 projetos alocados

SELECT nom_local, 
	COUNT(*) qtd_projeto
FROM projeto p
GROUP BY nom_local
HAVING COUNT(*) > 2;

-- Utilizando subquery:

-- Listando o nome do empregado e o nome do respectivo departamento para todos os empregados que n�o est�o alocados em projetos com:

-- NOT EXISTS

SELECT e.nom_empregado, d.nom_depto
FROM empregado e
JOIN departamento d ON d.cod_depto = e.cod_depto
WHERE NOT EXISTS (
			SELECT 1
			FROM alocacao a
			WHERE a.num_matricula = e.num_matricula);

-- NOT IN

SELECT nom_empregado, nom_depto
	FROM empregado e
	JOIN departamento d ON d.cod_depto	= e.cod_depto
	WHERE e.num_matricula NOT IN
					(SELECT num_matricula FROM alocacao a)

-- LEFT JOIN

SELECT nom_empregado, nom_depto
	FROM empregado e
	JOIN departamento d ON d.cod_depto	= e.cod_depto
	LEFT JOIN alocacao a ON a.num_matricula = e.num_matricula
	WHERE a.num_matricula IS NULL

-- Listando o empregado, o n�mero de horas e o projeto cuja aloca��o de horas no projeto � maior do que a m�dia de aloca��o do referido projeto.

SELECT nom_empregado, num_horas, p.nom_projeto
		media,
		SUM(a.num_horas) AS qtd_horas
	FROM empregado e
	JOIN alocacao a ON a.num_matricula = e.num_matricula
	JOIN projeto p ON a.cod_projeto = p.cod_depto
	JOIN (SELECT cod_projeto, 
			AVG(num_horas) media
				FROM alocacao a
				GROUP BY cod_projeto) a_media ON a.cod_projeto = a_media.cod_projeto
				GROUP BY  a.cod_projeto, nom_empregado, nom_projeto, media, num_horas
				HAVING SUM(num_horas) > media;

-- Usando COALESCE
-- impede que um valor nulo apare�a na query final

SELECT nom_empregado, sex_empregado, 
CASE sex_empregado WHEN 'M' THEN 'Masculino'
	ELSE 'Feminino' 
	END AS g�nero,
	COALESCE (CAST (num_matricula_supervisor AS char), 'n�o cadastrado') AS num_n�o_nulo
FROM empregado

-- FULL OUTER JOIN - mostrando valores nulos das 2 tabelas

SELECT d.nom_depto, 
	SUM(val_salario)
FROM empregado e
FULL OUTER JOIN departamento d ON e.cod_depto = d.cod_depto
GROUP BY d.nom_depto, e.cod_depto;

-- Usando WITH e INNER JOIN
-- Somando os valores de sal�rios por departamento

WITH
	t1 AS (
		SELECT d.nom_depto, e.cod_depto,
	SUM(val_salario) as soma_depto
FROM empregado e
FULL OUTER JOIN departamento d ON e.cod_depto = d.cod_depto
GROUP BY d.nom_depto, e.cod_depto
)
SELECT *
FROM empregado e
	INNER JOIN t1 on t1.cod_depto = e.cod_depto;

-- Usando WITH e UNION
-- Separando funcion�rios Paulistas e Mineiros dos outros funcon�rios

WITH 
	Paulistas as (
				SELECT *
				FROM empregado e 
				WHERE sig_uf = 'SP' ),
	Mineiros as (	
			SELECT *
			FROM empregado e 
			WHERE sig_uf = 'MG' )
	SELECT *
	FROM Paulistas
UNION 
	SELECT *
	FROM Mineiros;