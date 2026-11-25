# Sistema de Gestão de Loja de Tecnologia - TechStore

Projeto acadêmico de banco de dados relacional desenvolvido em MySQL, com o objetivo de organizar as informações de uma loja de produtos de tecnologia (e-commerce) e centralizar as regras de negócio por meio de stored procedures.

![Diagrama EER do banco loja_tech](eer.png)

## 1. Pré-requisitos

- MySQL Server 8.0.13 ou superior.
- MySQL Workbench, ou outra ferramenta compatível com MySQL.

## 2. Contextualização

A TechStore vende notebooks, celulares, periféricos, monitores e dispositivos de armazenamento. À medida que o catálogo e o volume de pedidos crescem, algumas operações do dia a dia tornam-se difíceis de controlar:

- Reajustar preços de uma categoria inteira produto por produto, sem limites definidos.
- Registrar cadastros e alterações sem deixar rastro.
- Consultar o histórico de um cliente, com pedidos e valores, em várias consultas separadas.
- Garantir que cada sistema (site, aplicativo ou sistema interno) aplique as mesmas regras.

O projeto resolve esses pontos ao concentrar a lógica de negócio no próprio banco. As operações são executadas por stored procedures, que validam os dados antes de alterá-los, registram as ações relevantes em uma tabela de auditoria e devolvem resultados padronizados.

## 3. Objetivos

- Aplicar os conceitos de stored procedures do MySQL na prática.
- Utilizar parâmetros de entrada (`IN`) e de saída (`OUT`) nas rotinas.
- Implementar validações de regras de negócio antes de alterar os dados.
- Retornar múltiplos conjuntos de resultados em uma única chamada.
- Registrar operações relevantes na tabela de auditoria `log_operacoes`.
- Desenvolver consultas que auxiliem a tomada de decisão em diferentes setores da loja.
- Comparar situações em que views são mais adequadas do que stored procedures.

## 4. Tecnologias Utilizadas

- **MySQL:** sistema gerenciador de banco de dados.
- **MySQL Workbench:** criação, execução e testes dos scripts.
- **SQL:** criação de tabelas, inserção de dados, consultas, stored procedures e views.
- **GitHub:** armazenamento e compartilhamento dos scripts do projeto.

## 5. Modelagem do Banco de Dados

O banco `loja_tech` é composto por seis tabelas relacionadas. O diagrama EER no topo deste documento mostra a estrutura completa.

### 5.1 Tabelas

**categorias**: agrupa os produtos por tipo.

| Campo | Tipo | Descrição |
|---|---|---|
| `id_categoria` | INT | Chave primária, com autoincremento. |
| `nome` | VARCHAR(100) | Nome da categoria, obrigatório. |
| `descricao` | TEXT | Descrição da categoria. |
| `ativo` | BOOLEAN | Indica se a categoria está ativa. Padrão: verdadeiro. |
| `criado_em` | DATETIME | Data de criação. Padrão: data atual. |

**produtos**: catálogo de produtos à venda.

| Campo | Tipo | Descrição |
|---|---|---|
| `id_produto` | INT | Chave primária, com autoincremento. |
| `id_categoria` | INT | Chave estrangeira para `categorias`. |
| `nome` | VARCHAR(200) | Nome do produto, obrigatório. |
| `descricao` | TEXT | Descrição do produto. |
| `preco` | DECIMAL(10,2) | Preço unitário, obrigatório. |
| `estoque` | INT | Quantidade em estoque. Padrão: 0. |
| `estoque_minimo` | INT | Quantidade mínima desejada em estoque. Padrão: 5. |
| `ativo` | BOOLEAN | Indica se o produto está à venda. Padrão: verdadeiro. |
| `criado_em` | DATETIME | Data de criação. |
| `atualizado_em` | DATETIME | Data da última atualização. |

**clientes**: cadastro dos clientes da loja.

| Campo | Tipo | Descrição |
|---|---|---|
| `id_cliente` | INT | Chave primária, com autoincremento. |
| `nome` | VARCHAR(150) | Nome do cliente, obrigatório. |
| `email` | VARCHAR(200) | E-mail, obrigatório e único. |
| `cpf` | CHAR(11) | CPF, obrigatório e único. |
| `telefone` | VARCHAR(15) | Telefone de contato. |
| `data_nascimento` | DATE | Data de nascimento. |
| `ativo` | BOOLEAN | Indica se o cadastro está ativo. Padrão: verdadeiro. |
| `criado_em` | DATETIME | Data do cadastro. |

**pedidos**: registro dos pedidos realizados pelos clientes.

| Campo | Tipo | Descrição |
|---|---|---|
| `id_pedido` | INT | Chave primária, com autoincremento. |
| `id_cliente` | INT | Chave estrangeira para `clientes`. |
| `data_pedido` | DATETIME | Data e hora do pedido. |
| `status` | ENUM | Situação do pedido: `pendente`, `processando`, `enviado`, `entregue` ou `cancelado`. Padrão: `pendente`. |
| `valor_total` | DECIMAL(10,2) | Valor total do pedido. Padrão: 0,00. |
| `observacao` | TEXT | Observações do pedido. |
| `criado_em` | DATETIME | Data de criação do registro. |
| `atualizado_em` | DATETIME | Data da última atualização. |

**itens_pedido**: detalha os produtos de cada pedido.

| Campo | Tipo | Descrição |
|---|---|---|
| `id_item` | INT | Chave primária, com autoincremento. |
| `id_pedido` | INT | Chave estrangeira para `pedidos`. |
| `id_produto` | INT | Chave estrangeira para `produtos`. |
| `quantidade` | INT | Quantidade do produto no pedido. Padrão: 1. |
| `preco_unitario` | DECIMAL(10,2) | Preço do produto no momento da compra. |
| `subtotal` | DECIMAL(10,2) | Calculado automaticamente: quantidade multiplicada pelo preço unitário. |

**log_operacoes**: auditoria das operações realizadas pelas stored procedures.

| Campo | Tipo | Descrição |
|---|---|---|
| `id_log` | INT | Chave primária, com autoincremento. |
| `tabela_afetada` | VARCHAR(100) | Nome da tabela alterada pela operação. |
| `operacao` | VARCHAR(50) | Tipo da operação, como `UPDATE_PRECO`. |
| `descricao` | TEXT | Detalhes da operação. |
| `usuario` | VARCHAR(100) | Usuário do banco que executou a operação. |
| `data_operacao` | DATETIME | Data e hora da operação. |

### 5.2 Relacionamentos e cardinalidade

- **Categorias e produtos (1:N):** uma categoria pode possuir vários produtos, mas cada produto pertence a uma única categoria.
- **Clientes e pedidos (1:N):** um cliente pode realizar vários pedidos, mas cada pedido pertence a um único cliente.
- **Pedidos e itens de pedido (1:N):** um pedido pode conter vários itens, mas cada item pertence a um único pedido.
- **Produtos e itens de pedido (1:N):** um produto pode aparecer em vários itens de pedido, mas cada item refere-se a um único produto.

A tabela `log_operacoes` não possui chave estrangeira. Ela registra as operações de forma independente, para que o histórico seja preservado.

A integridade referencial é garantida pelas chaves estrangeiras, que impedem, por exemplo, a criação de um pedido para um cliente inexistente.

## 6. Consultas SQL Desenvolvidas

O arquivo `queries.sql` contém dez consultas, cada uma respondendo a uma necessidade de um setor da loja:

| Nº | Situação | Recursos utilizados |
|---|---|---|
| 1 | O marketing precisa do nome e do e-mail de todos os clientes para um comunicado geral. | `SELECT`, `FROM` |
| 2 | A vitrine promocional precisa de produtos que custem menos de R$ 500,00. | `WHERE` com comparação |
| 3 | A equipe de atendimento precisa ver todos os dados dos pedidos pendentes. | `WHERE` com igualdade |
| 4 | O catálogo deve ser exibido do produto mais caro para o mais barato. | `ORDER BY ... DESC` |
| 5 | O cliente quer ver os produtos cujo nome contém "Monitor". | `LIKE` |
| 6 | O gerente de logística quer os periféricos com mais de 40 unidades em estoque. | `WHERE` composto com `AND` |
| 7 | A gerência quer o total de clientes cadastrados. | `COUNT(*)` com alias |
| 8 | A diretoria quer o faturamento bruto, somando todos os pedidos. | `SUM()` com alias |
| 9 | Para facilitar a leitura do catálogo, cada produto deve aparecer com o nome da sua categoria. | `INNER JOIN` |
| 10 | O atendimento quer os pedidos de uma cliente específica. | `INNER JOIN` com `WHERE` |

## 7. Stored Procedures Desenvolvidas

O arquivo `stored_procedure.sql` cria sete procedures. Elas estão organizadas em três grupos: consultas, cadastro e atualização de dados, e cálculos com retorno por parâmetro.

### 7.1 Procedures de consulta

**listar_categorias_ativas**

Lista as categorias ativas, com id, nome e descrição, em ordem alfabética.

- Parâmetros: nenhum.
- Retorno: um conjunto de resultados.

**buscar_pedidos_por_status**

Retorna os pedidos que possuem o status informado.

- Parâmetros: `IN p_status VARCHAR(20)`, com valores como `pendente`, `processando`, `enviado`, `entregue` ou `cancelado`.
- Retorno: um conjunto de resultados com `id_pedido`, `id_cliente`, `data_pedido` e `valor_total`.

**consultar_extrato_cliente**

Gera o extrato de um cliente em três conjuntos de resultados: dados cadastrais, lista de pedidos e resumo financeiro. O resumo considera apenas pedidos não cancelados. Se o cliente não existir, a procedure retorna uma mensagem de erro.

- Parâmetros: `IN p_id_cliente INT`.
- Retorno: três conjuntos de resultados ou uma mensagem de erro.

### 7.2 Procedures de cadastro e atualização

**inserir_categoria**

Cadastra uma nova categoria. As colunas `ativo` e `criado_em` recebem os valores padrão da tabela.

- Parâmetros: `IN p_nome VARCHAR(100)`, `IN p_descricao TEXT`.
- Retorno: nenhum.

**atualizar_telefone_cliente**

Atualiza o telefone de um cliente, identificado pelo id.

- Parâmetros: `IN p_id_cliente INT`, `IN p_telefone VARCHAR(15)`.
- Retorno: nenhum.

### 7.3 Procedures de cálculo e reajuste

**contar_produtos_categoria**

Conta os produtos de uma categoria e devolve o total pelo parâmetro de saída.

- Parâmetros: `IN
