CREATE DATABASE PraticaGlobal_31611542_04;
GO

USE PraticaGlobal_31611542_04;
GO

CREATE TABLE tblCliente(
	Mat INT NOT NULL,
	Nome VARCHAR (50),
	Sexo VARCHAR (1)
)

CREATE TABLE tblNotaFiscal(
	NumNotaFiscal INT NOT NULL,
	Data DATETIME,
	ValorNota FLOAT,
	MatCli INT
)

CREATE TABLE tblProduto(
	CB INT NOT NULL,
	DescProd TEXT,
	QtdeAtual FLOAT,
	QtdeMin INT
)

CREATE TABLE tblItensNota(
	CB INT NOT NULL,
	NumNotaFiscal INT,
	QtdeVend INT,
	valorUnit FLOAT,
	Subtotal FLOAT
)

ALTER TABLE tblCliente ADD CONSTRAINT PK_CLIENTE PRIMARY KEY (Mat);
ALTER TABLE tblNotaFiscal ADD CONSTRAINT PK_NOTAFISCAL PRIMARY KEY (NumNotaFiscal);
ALTER TABLE tblProduto ADD CONSTRAINT PK_PRODUTO PRIMARY KEY (CB);
--ALTER TABLE tblItensNota ADD CONSTRAINT PK_ITENSNOTAS PRIMARY KEY (CB);

ALTER TABLE tblNotaFiscal ADD CONSTRAINT FK_NOTAFISCAL_PKCLIENTE FOREIGN KEY (MatCli) REFERENCES tblCliente (Mat);
ALTER TABLE tblItensNota ADD CONSTRAINT FK_ITENSNOTA_PKNOTAFISCAL FOREIGN KEY (NumNotaFiscal) REFERENCES tblNotaFiscal (NumNotaFiscal);
ALTER TABLE tblItensNota ADD CONSTRAINT FK_ITENSNOTA_PKPRODUTO FOREIGN KEY (CB) REFERENCES tblProduto (CB);

--Comandos para inser��o dos dados

INSERT INTO tblCliente VALUES (123,'Paulo Mendes','M');
INSERT INTO tblCliente VALUES (456,'Patr�cia Dias','F');
INSERT INTO tblCliente VALUES (789,'Rafael Garcia','M');
INSERT INTO tblCliente VALUES (909,'Adelaide Pereira','F');

INSERT INTO tblNotaFiscal VALUES (100100,'05/05/2016',3200.00,123);
INSERT INTO tblNotaFiscal VALUES (200200,'06/05/2016',1900.00,456);
INSERT INTO tblNotaFiscal VALUES (300300,'05/07/2016',800.00,123);

INSERT INTO tblProduto VALUES (2789,'Mouse �tico',100,20);
INSERT INTO tblProduto VALUES (2790,'HD 500 GB',90,10);
INSERT INTO tblProduto VALUES (2791,'Teclado',20,5);

INSERT INTO tblItensNota VALUES (2789,100100,100,32,3200);
INSERT INTO tblItensNota VALUES (2790,200200,10,190.00,1900.00);
INSERT INTO tblItensNota VALUES (2791,300300,20,20,400.00);
INSERT INTO tblItensNota VALUES (2790,300300,10,40,400.00);

/*a) Crie uma View, chame essa View com o nome VEstoque, que exiba o c�digo do produto,
nome do produto e a quantidade em estoque.*/

CREATE VIEW VEstoque AS SELECT 
	CB AS Codigo, DescProd AS Produto, QtdeAtual AS Quantidade FROM tblProduto;

DROP VIEW VEstoque;

DECLARE @CodProd AS INT = 2790
SELECT * FROM VEstoque WHERE Codigo=@CodProd;

/*b) Crie uma View, denominada VCadCliente, a qual permita a inser��o de novos clientes na
View e automaticamente na Tabela Cliente.*/

CREATE VIEW VCadCliente AS SELECT Mat AS Matricula, Nome, Sexo FROM tblCliente;
SELECT * FROM VCadCliente;
INSERT INTO VCadCliente VALUES (100,'Ant�nio Prado','M');

/*c) Insira um campo cpf na tabela cliente; Crie uma function que valide um cpf e permita a
inser��o de apenas clientes com cpfs v�lidos.*/

/*Cria��o da fun��o de valida��o*/
CREATE FUNCTION CPF_VALIDO(@CPF VARCHAR(11))
RETURNS CHAR(1)
AS
BEGIN
  DECLARE @INDICE INT,
          @SOMA INT,
          @DIG1 INT,
          @DIG2 INT,
          @CPF_TEMP VARCHAR(11),
          @DIGITOS_IGUAIS CHAR(1),
          @RESULTADO CHAR(1)
          
  SET @RESULTADO = 'N'

  /*
      Verificando se os digitos s�o iguais
      A Principio CPF com todos o n�meros iguais s�o Inv�lidos
      apesar de validar o Calculo do digito verificado
      EX: O CPF 00000000000 � inv�lido, mas pelo calculo
      Validaria
  */

  SET @CPF_TEMP = SUBSTRING(@CPF,1,1)

  SET @INDICE = 1
  SET @DIGITOS_IGUAIS = 'S'

  WHILE (@INDICE <= 11)
  BEGIN
    IF SUBSTRING(@CPF,@INDICE,1) <> @CPF_TEMP
      SET @DIGITOS_IGUAIS = 'N'
    SET @INDICE = @INDICE + 1
  END;

  --Caso os digitos n�o sej�o todos iguais Come�o o calculo do digitos
  IF @DIGITOS_IGUAIS = 'N'
  BEGIN
    --C�lculo do 1� d�gito
    SET @SOMA = 0
    SET @INDICE = 1
    WHILE (@INDICE <= 9)
    BEGIN
      SET @Soma = @Soma + CONVERT(INT,SUBSTRING(@CPF,@INDICE,1)) * (11 - @INDICE);
      SET @INDICE = @INDICE + 1
    END

    SET @DIG1 = 11 - (@SOMA % 11)

    IF @DIG1 > 9
      SET @DIG1 = 0;

    -- C�lculo do 2� d�gito }
    SET @SOMA = 0
    SET @INDICE = 1
    WHILE (@INDICE <= 10)
    BEGIN
      SET @Soma = @Soma + CONVERT(INT,SUBSTRING(@CPF,@INDICE,1)) * (12 - @INDICE);
      SET @INDICE = @INDICE + 1
    END

    SET @DIG2 = 11 - (@SOMA % 11)

    IF @DIG2 > 9
      SET @DIG2 = 0;

    -- Validando
    IF (@DIG1 = SUBSTRING(@CPF,LEN(@CPF)-1,1)) AND (@DIG2 = SUBSTRING(@CPF,LEN(@CPF),1))
      SET @RESULTADO = 'S'
    ELSE
      SET @RESULTADO = 'N'
  END
 
	/*IF LEN(@CPF) < 11
		SET @RESULTADO = 'N'
	ELSE
		SET @RESULTADO = 'S'*/
	RETURN @RESULTADO
END
/*Fim fun��o de valida��o*/

SELECT * FROM tblCliente;
ALTER TABLE tblCliente ADD Cpf VARCHAR(20);
DELETE FROM tblCliente WHERE Mat = 102;

DECLARE @CPF AS VARCHAR(20) = '36464646464';
--PRINT @CPF;
BEGIN TRANSACTION
 BEGIN
  DECLARE @BOOL AS VARCHAR = (SELECT DBO.CPF_VALIDO(@CPF));
    IF @BOOL = 'S'
	  INSERT INTO tblCliente VALUES ('102','Bruna Hannely','F',@CPF);
    ELSE
	  PRINT 'N�o cadastrado';
IF @@ERROR < 1
  COMMIT
ELSE
  ROLLBACK
END

--Teste de valida��o de Cpf
SELECT DBO.CPF_VALIDO('13738806601')

/*d) Crie uma transa��o que emita uma NotaFiscal e seus Itens, protegida transacionalmente e
sem erros.*/

BEGIN TRANSACTION EmissaoNotaFiscal;

	DECLARE @MatCliente INT = 100;
	DECLARE @CbProduto INT = 2791;
	DECLARE @NumNotaFiscal INT = 400400;
	DECLARE @QtDeVendas INT = 0;
	DECLARE @ValUnit FLOAT = 0.0;
	DECLARE @SubTotal FLOAT = 0.0;

	DECLARE @ClienteExistente AS BIT = (SELECT Mat FROM tblCliente WHERE Mat = @MatCliente)

	IF @ClienteExistente = 1
		--PRINT 'Cliente Existe';
		BEGIN TRANSACTION InsercaoDeItens
		 
		 INSERT INTO tblItensNota VALUES (@CbProduto,@NumNotaFiscal,@QtDeVendas,@ValUnit,@SubTotal);
		 INSERT INTO tblNotaFiscal VALUES (@NumNotaFiscal,SYSDATETIME(),@SubTotal,@MatCliente);
		
		IF @@ERROR = 0
		 COMMIT TRANSACTION InsercaoDeItens
		ELSE
		 ROLLBACK InsercaoDeItens

		SELECT * FROM tblNotaFiscal WHERE NumNotaFiscal = @NumNotaFiscal;
	END
	ELSE
		--PRINT 'Cliente Inexistente';
		--IF dbo.CPF_VALIDO('12312312309') = 'S'
			--INSERT INTO tblCliente VALUES (@MatCliente,'Antonio Lunard','M','12312312309')
		ROLLBACK
	END
	
IF @@ERROR = 0
	COMMIT;
ELSE
	ROLLBACK;
END

	
	SELECT * FROM tblItensNota;
	SELECT * FROM tblNotaFiscal;
	select * from tblProduto;
	SELECT * FROM tblCliente;
	
END

/*e) Crie uma transa��o que emita uma NotaFiscal e seus Itens, protegida transacionalmente e
com erros, for�ando o roolback.*/



/*f) Crie uma trigger denominada, BaixarEstoque, na qual permita ao inlcuir um item na tabela itensNota, 
baixe o estoque daquele produto inserido.*/



/*g)Crie  um  Cursor,  o  qual  deve  apagar  todos  os  itens  de  uma  nota  fiscal antes  de  excluir  a mesma.*/



/*h)Crie  uma  trigger  denominada,  Atualizada  Subtotal,  na  qual  permita  ao  inlcuir  um  item  na 
tabela itensNota, e a partir desse momento o valor subtotal seja calculado*/



/*i)Crie   uma StoreProcedure denominada, CancelarNota, que   atrav�s  da   utiliza��o   de cursores, volte os produtos para o estoque, 
passe o status do item para cancelado, assim como o campo status da tabela notafiscal
.*/



/*j)Crie  uma  tabela  TributoNF,  o  qual  ir�  armazenar  o  n�mero  da  NotaFiscal  e  o  Tributo  da mesma,  considere  18 %  
de  icms  para  esse  c�lculo.Ao  inserir  ou  atulizar  o  status  de  uma NotaFiscal para cancelado o imposto dever� ser 
calculado ou zerado na tabela Tributo.*/



/*k)Crie uma StoreProcedure denominada, Sp_ProdutosemFalta que gere uma lista com todos os produtos onde a quantidadeMin seja 
maior que a Qtde em estoque.*/



/*l)Crie  uma  SP,  chamada  ConsultarEstoque  sendo  que  ao  passar  o  par�metro  c�digo  de barra, devolva o c�digo, o nome e 
a quantidade em estoque.*/



/*m)Quer  melhorar sua  aplica��o,  crie  uma  tabela  denominada  Ordem  de  Compra,  a  qual 
dever� ser emitidada para um fornecedor. Toda ordem de compra possui itenscomprados. 
Essa  rela��o  deve  possuir  a  op��o  cascade  de  modo  que  ao  excluir  uma  Ordem  de 
Compra, todos os seus itens devem ser exclu�das.*/



/*N)Crie  uma  SP -chamada  ReceberOrdem  de  compra  ,    qual  dever�  atulizar  a  quantidade  de 
produtos e ter seu status da Ordem de compra, passada para �Recebida�. O  recebimento  do item dever� incrementar o estoque.*/



/*O) Construa um script o qual permita que ao emitir uma Nota fiscal com 03 produtos, a mesma 
dever� estar protegida transacionalmente e a emiss�o da NF s� ser� poss�vel se a quantidade do item estiver dispon�vel no estoque.*/



/*P)  Crie  um  cursor  que  percorra  todos  os  clientes  e  insira  um  email  com  a  forma��o NomeCliente@gmail.com
, ou seja, o cliente Paulo Mendes dever� ser Paulo.Mendes@gmail.com, a inser��o do ponto poder� ser feito a seu crit�rio.*/



/*Q) Vamos  imaginar  uma  situa��o:  Voc�  necessita  atribuir  uma  permiss�o  para  realizar  select  em  uma 
tabela,  para  os  membros  do  grupo  RH,  que  �  um  grupo Windows,  por�m  voc�  n�o  quer  que  a  Maria, 
membro desse grupo, tenha permiss�o para acessar essa tabela. Voc� ir� usar o comando GRANT para o grupo RH e usar o 
comando DENY para a Maria. Isso far� com que Maria n�o tenha nenhum tipo de acesso � tabela em quest�o, sem prejudicar os 
outros membros do grupo RH.
Siga   o   tutorial: https://angmaximo.wordpress.com/2013/04/17/entendendo-comandos-grant-revoke-deny/ */


/*S) Siga    o    tutorial    para    realizar    a    c�pia    (Backup)    de    seu    banco    de    dados. 
http://www.macoratti.net/sql5_mng.htm */