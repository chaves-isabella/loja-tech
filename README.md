# Atividade: Stored Procedures - Banco loja_tech (TechStore)

![Diagrama EER do banco loja_tech](eer.png)

## Diagrama EER

O diagrama acima representa a estrutura do banco `loja_tech`, com as seis tabelas e seus relacionamentos:

- Uma categoria pode possuir vários produtos.
- Um cliente pode realizar vários pedidos.
- Um pedido pode conter vários itens.
- Um produto pode aparecer em vários itens de pedido.

A tabela `log_operacoes` é independente das demais e armazena o registro de auditoria das operações executadas pelas procedures.

---

**Disciplina:** [nome da disciplina]
**Professor(a):** [nome do professor(a)]
**Integrantes:** [nome completo dos integrantes]
**Versão do MySQL utilizada:** 8.0.13 ou superior

---

## 1. Sobre o Projeto

O projeto TechStore tem como objetivo desenvolver rotinas de banco de dados para a gestão de uma loja de produtos de tecnologia (e-commerce). O banco `loja_tech` armazena categorias, produtos, clientes, pedidos e itens de pedido. Sobre essa estrutura, foram implementadas stored procedures que encapsulam operações comuns do dia a dia, como cadastro de categorias, consulta de pedidos e contagem de produtos.

A proposta é centralizar a lógica de negócio no próprio banco, de modo que diferentes sistemas (site, aplicativo ou sistema interno) possam executar as mesmas operações de forma padronizada e segura.

## 2. Objetivos do Projeto

- Aplicar os conceitos de stored procedures do MySQL na prática.
- Utilizar parâmetros de entrada (`IN`) e de saída (`OUT`) nas rotinas.
- Implementar validações antes de alterar os dados.
- Desenvolver consultas que auxiliem a tomada de decisão em diferentes setores da loja.

## 3. Tecnologias Utilizadas

- **MySQL:** sistema gerenciador de banco de dados.
- **MySQL Workbench:** ferramenta utilizada para criação, execução e testes dos scripts.
- **SQL:** linguagem utilizada para criação de tabelas, inserção, consulta e stored procedures.
- **GitHub:** plataforma utilizada para armazenar e compartilhar os scripts do projeto.

## 4. Estrutura do Banco de Dados

O banco de dados `loja_tech` é composto por seis tabelas.

| Tabela | Descrição |
|---|---|
| `categorias` | Agrupa os produtos por tipo, como Notebooks, Smartphones e Periféricos. |
| `produtos` | Catálogo de produtos à venda, com preço, estoque e situação de ativação. |
| `clientes` | Cadastro dos clientes da loja, com nome, e-mail, CPF e telefone. |
| `pedidos` | Registro dos pedidos realizados, com status e valor total. |
| `itens_pedido` | Detalhe dos produtos de cada pedido, com quantidade e preço unitário. |
| `log_operacoes` | Registro de auditoria das operações executadas pelas stored procedures. |

## 5. Arquivos do Projeto

| Arquivo | Descrição |
|---|---|
| `script.sql` | Cria o banco `loja_tech` e suas seis tabelas. |
| `inserts.sql` | Carrega os dados iniciais de categorias, produtos, clientes, pedidos e itens de pedido. |
| `stored_procedure.sql` | Cria as cinco stored procedures do projeto e, ao final, lista as procedures criadas. |
| `queries.sql` | Contém as dez consultas desenvolvidas na atividade. |
| `eer.png` | Diagrama EER do banco de dados. |
| `README.md` | Este documento. |

## 6. Como Executar o Projeto

### 6.1 Instalação

Instale o MySQL Server (versão 8.0.13 ou superior) e o MySQL Workbench.

### 6.2 Ordem de execução

Execute os arquivos na seguinte ordem:

1. `script.sql`: cria o banco e as tabelas.
2. `inserts.sql`: carrega os dados iniciais.
3. `stored_procedure.sql`: cria as stored procedures.
4. `queries.sql`: executa as consultas (opcional).

No MySQL Workbench, abra cada arquivo e execute o script inteiro com o ícone de raio (**Execute All**) ou com **Ctrl+Shift+Enter**.

> **Atenção:** o `inserts.sql` deve ser executado apenas uma vez, depois que o banco foi criado. Para recomeçar do zero, apague o banco `loja_tech` e execute novamente o `script.sql`, seguido dos demais.

### 6.3 Verificação das procedures

Ao final do `stored_procedure.sql`, o comando abaixo lista as procedures do banco:

```sql
show procedure status where db = 'loja_tech';
```

A lista deve conter as cinco procedures descritas na seção 7.

## 7. Stored Procedures Desenvolvidas

| Procedure | Finalidade |
|---|---|
| `listar_categorias_ativas` | Lista as categorias ativas em ordem alfabética. |
| `buscar_pedidos_por_status` | Retorna os pedidos com o status informado. |
| `inserir_categoria` | Cadastra uma nova categoria. |
| `atualizar_telefone_cliente` | Atualiza o telefone de um cliente pelo seu identificador. |
| `contar_produtos_categoria` | Conta os produtos de uma categoria e devolve o total por parâmetro de saída. |

## 8. Como Testar as Procedures

Cada procedure pode ser testada com um comando `call`. Execute os testes após o `stored_procedure.sql` ter sido executado com sucesso, de preferência no MySQL Workbench, uma linha de cada vez, com **Ctrl+Enter**.

| Ordem | Comando | Resultado esperado |
|---|---|---|
| 1 | `call listar_categorias_ativas();` | Cinco categorias, em ordem alfabética: Armazenamento, Monitores, Notebooks, Periféricos e Smartphones. |
| 2 | `call buscar_pedidos_por_status('entregue');` | Um pedido (número 1), do cliente 1, com valor total de 3749.80. |
| 3 | `call contar_produtos_categoria(3, @total);` seguido de `select @total as total_produtos;` | Três produtos na categoria Periféricos. |
| 4 | `call inserir_categoria('Acessórios', 'Cabos, adaptadores e suportes');` seguido de `select * from categorias;` | A nova categoria aparece na lista, com id 6. |
| 5 | `call atualizar_telefone_cliente(1, '11999998888');` seguido de `select id_cliente, nome, telefone from clientes where id_cliente = 1;` | O telefone da Ana Silva passa a ser 11999998888. |

Observações sobre os testes:

- Os testes 4 e 5 alteram dados. Execute cada um uma única vez, ou em uma cópia do banco. Se o teste 4 for repetido, a categoria é inserida novamente com outro id.
- No teste 3, a variável `@total` só recebe valor depois do `call`. Por isso, o `select` deve ser executado logo em seguida.
- Se um resultado não bater com o esperado, confira se o `inserts.sql` foi executado antes e se não há outros testes alterando os mesmos dados.

## 9. Conceitos de Banco de Dados Aplicados

- Banco de dados relacional e modelagem de dados (diagrama EER).
- Chaves primárias e chaves estrangeiras.
- Integridade referencial e restrições de dados.
- Stored procedures e delimitadores de comandos.
- Parâmetros de entrada (`IN`) e saída (`OUT`).
- Variáveis locais e estruturas condicionais (`IF`/`ELSEIF`).
- Consultas com filtros (`WHERE`, `LIKE`), ordenação e funções de agregação.
- Consultas com junções (`INNER JOIN`).

## 10. Importância do Projeto

A centralização da lógica de negócio no banco de dados facilita a manutenção e a padronização das operações da loja. Uma regra definida em uma procedure passa a valer para todos os sistemas que utilizam o banco.

Além disso, as procedures permitem conceder acesso apenas à execução de operações específicas, sem liberar alterações diretas nas tabelas. Isso reduz o risco de erros e de acessos indevidos aos dados.

## 11. Informações Acadêmicas

| Campo | Descrição |
|---|---|
| Projeto | Sistema de Gestão de Loja de Tecnologia - TechStore |
| Disciplina | [nome da disciplina] |
| Desenvolvimento | Individual |
| Banco de Dados | MySQL |
| Ferramenta | MySQL Workbench |
| Linguagem | SQL |
| Aluno(a) | [nome completo] |
| Professor(a) | [nome do professor(a)] |

## 12. Considerações Finais

O desenvolvimento deste projeto permitiu aplicar, de forma prática, os conceitos de banco de dados relacional e de stored procedures. A criação das rotinas e das validações possibilitou compreender como um banco de dados pode representar e proteger as regras de um processo comercial real.

Projeto desenvolvido individualmente para aplicação dos conhecimentos de Banco de Dados e SQL.
