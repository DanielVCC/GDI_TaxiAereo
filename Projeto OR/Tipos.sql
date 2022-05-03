-- TIPO PESSOA --
-- TIPO NOT FINAL (PERMITE CRIAÇÃO DE SUBTIPO E NÃO É POSSÍVEL INSERIR DADOS, POIS É APENAS UM MOLDE) -- 
-- E NOT INSTANTIABLE (TIPOS ABSTRADOS: NÃO PODEM TER INSTÂNCIAS DE OBJETOS CRIADAS EM TABELAS) --
-- CLIENTE E FUNCIONÁRIO HERDAM DE PESSOA --
CREATE OR REPLACE TYPE tp_pessoa AS OBJECT (
    
    cpf VARCHAR2(15),
    nome VARCHAR2(40),
    telefone tp_telefone,
    endereco tp_endereco,
    MEMBER PROCEDURE print_info
    
) NOT FINAL NOT INSTANTIABLE;

/

-- TELEFONE (USANDO VARRAY) --
-- TIPO VARRAY QUE POSSIBILITA INSERÇÃO E ARMAZENAMENTO DE MÚLTIPLOS TELEFONES --
CREATE OR REPLACE TYPE tp_telefone AS OBJECT (
    
    ddd NUMBER,
    numero NUMBER

);

/

-- CRIANDO TIPO ARRAY DE TELEFONES --
CREATE OR REPLACE TYPE tp_arr_telefone AS VARRAY (5) OF tp_telefone;

/
   
-- ENDEREÇO --
-- TIPO QUE ESTARÁ EM PESSOA (QUE CLIENTE E FUNCIONARIO HERDAM) --
CREATE OR REPLACE TYPE tp_endereco AS OBJECT (

    cep VARCHAR2 (12), 
    logradouro VARCHAR2 (40), 
    numero NUMBER, 
    complemento VARCHAR2 (20),
    bairro VARCHAR2 (20),
    estado VARCHAR2 (20),
    cidade VARCHAR2 (20)

);


/

-- CLIENTE --
-- HERDA DE PESSOA --
CREATE OR REPLACE TYPE tp_cliente UNDER tp_pessoa (

    data_cadastro DATE

);

/

-- FUNCIONÁRIO --
-- HERDA DE PESSOA --
CREATE OR REPLACE TYPE tp_funcionario UNDER tp_pessoa (

    turno_de_trabalho VARCHAR2(14),
    salario NUMBER,
    MEMBER FUNCTION renda_anual RETURN NUMBER,
    OVERRIDING MEMBER PROCEDURE print_info,
    CONSTRUCTOR FUNCTION tp_funcionario (x1 tp_funcionario) RETURN SELF AS RESULT

) NOT FINAL;

/

-- RENDA_ANUAL: MEMBER FUNCTION QUE CALCULA A RENDA ANUAL DO ENTREGADOR --
-- PRINT_INFO: OVERRIDING MEMBER FUNCTION QUE IMPRIME AS INFORMAÇÕES DO ENTREGADOR --
-- CONSTRUCTOR: PADRÃO --
CREATE OR REPLACE TYPE BODY tp_funcionario AS
MEMBER FUNCTION renda_anual RETURN NUMBER IS
    BEGIN
        RETURN salario*12;
    END;
OVERRIDING MEMBER PROCEDURE print_info IS
    BEGIN 
        DBMS_OUTPUT.PUT_LINE(nome);
        DBMS_OUTPUT.PUT_LINE(cpf);
        DBMS_OUTPUT.PUT_LINE(salario);
        DBMS_OUTPUT.PUT_LINE(turno_de_trabalho);
    END;
CONSTRUCTOR FUNCTION tp_funcionario (x1 tp_funcionario) RETURN SELF AS RESULT IS
    BEGIN
        cpf := x1.cpf; 
        nome := x1.nome; 
        telefone := x1.telefone;
        endereco := x1.endereco;
        salario := x1.salario; 
        turno_de_trabalho := x1.turno_de_trabalho; 
        RETURN; 
    END;
END;


/

-- ATENDENTE --
-- HERDA DE FUNCIONÁRIO --
CREATE OR REPLACE TYPE tp_atendente UNDER tp_funcionario (

    clientes_atendidos NUMBER,
    FINAL MAP MEMBER FUNCTION qntd_clientes_atendidos RETURN NUMBER
);

/

/

-- QNTD_CLIENTES_ATENDIDOS: FINAL MAP MEMBER QUE RETORNA A QUANTIDADE DE TELEFONES CADASTRADOS DE UM CLIENTE --
CREATE OR REPLACE TYPE BODY tp_atendente AS 
FINAL MAP MEMBER FUNCTION qntd_clientes_atendidos RETURN NUMBER IS
selfCnt NUMBER;
    BEGIN
        SELECT COUNT(*) INTO selfCnt
        FROM TABLE(SELF.clientes_atendidos);
        RETURN selfCnt;
    END;
END;

/

-- PILOTO --
-- HERDA DE FUNCIONÁRIO --
CREATE OR REPLACE TYPE tp_piloto UNDER tp_funcionario (

    horas_de_voo NUMBER

);

/

-- ADICIONANDO DATA DE NASCIMENTO EM PESSOA --
-- CASCADE: PROPAGA A MUDANÇA PARA TIPOS DEPENDENTES -- 
ALTER TYPE tp_pessoa ADD ATTRIBUTE (data_nascimento DATE) CASCADE;

/

-- CUPOM --
-- PODE OU NÃO PERTENCER (REFERENCIAR) A UM CLIENTE --
CREATE OR REPLACE TYPE tp_promocao AS OBJECT (
    
    codigo_promocional NUMBER,
    data_de_termino DATE,
    desconto NUMBER

    cliente REF tp_cliente,

    ORDER MEMBER FUNCTION comparaDesconto (SELF IN OUT NOCOPY tp_promocao, c tp_promocao) RETURN NUMBER

);

/

-- COMPARA_DESCONTO: ORDER MEMBER FUNCTION QUE COMPARA DESCONTOS E RETORNA UM TEXTINHO --
CREATE OR REPLACE TYPE BODY tp_promocao AS
ORDER MEMBER FUNCTION comparaDesconto (SELF IN OUT NOCOPY tp_promocao, c tp_promocao) RETURN NUMBER IS
    BEGIN
        IF SELF.desconto < c.desconto THEN 
            RETURN -1;
        ELSIF SELF.desconto > c.desconto THEN 
            RETURN 1;
        ELSE 
            RETURN 0;
        END IF;
    END;
END;

/

-- AUXILIA --
-- AUTORELACIONAMENTO QUE REFERENCIA PILOTOS --
-- REF: REFERENCIA OBJETOS ARMAZENADOS EM TABELAS -- 
CREATE OR REPLACE TYPE tp_auxilia AS OBJECT (

    auxiliador REF tp_piloto,
    auxiliado REF tp_piloto

);

/

-- HANGAR --
-- TERÁ APENAS SEU TIPO CRIADO, POIS É UMA NESTED TABLE DE RESTAURANTE --
CREATE OR REPLACE TYPE tp_prato AS OBJECT (

    nome_prato VARCHAR2 (50),
    preco NUMBER,
    categoria VARCHAR2 (30),
    codigo NUMBER

);






/* CHECKLIST

1. CREATE OR REPLACE TYPE ✅
2. CREATE OR REPLACE TYPE BODY ✅
3. MEMBER PROCEDURE ✅
4. MEMBER FUNCTION ✅
5. ORDER MEMBER FUNCTION ✅
6. MAP MEMBER FUNCTION ✅
7. CONSTRUCTOR FUNCTION ✅
8. OVERRIDING MEMBER ✅
9. FINAL MEMBER ⚠️ (acho que ja foi no final map member)
10. NOT INSTANTIABLE TYPE/MEMBER ✅
11. HERANÇA DE TIPOS (UNDER/NOT FINAL) ✅
12. ALTER TYPE ✅
13. CREATE TABLE OF 
14. WITH ROWID REFERENCES 
15. REF ✅
16. SCOPE IS 
17. INSERT INTO 
18. VALUE 
19. VARRAY ✅
20. NESTED TABLE 

*/
