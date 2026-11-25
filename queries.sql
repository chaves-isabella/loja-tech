use loja_tech;

-- 1. Listagem básica de clientes: nome e e-mail de todos os clientes
select nome, email
from clientes;

-- 2. Filtro por faixa de preço: produtos que custam menos de R$ 500,00
select nome, preco
from produtos
where preco < 500;

-- 3. Filtro por status de pedido: todas as colunas dos pedidos pendentes
select *
from pedidos
where status = 'pendente';

-- 4. Ordenação de catálogo: produtos do mais caro para o mais barato
select nome, preco
from produtos
order by preco desc;

-- 5. Busca textual parcial: produtos que contenham "Monitor" em qualquer parte do nome
select id_produto, nome, preco
from produtos
where nome like '%Monitor%';

-- 6. Filtro composto: produtos da categoria Periféricos (id 3) com mais de 40 unidades em estoque
select nome, estoque
from produtos
where id_categoria = 3
  and estoque > 40
order by estoque desc;

-- 7. Contagem total de clientes cadastrados
select count(*) as total_clientes
from clientes;

-- 8. Soma do valor de todos os pedidos (faturamento bruto)
select sum(valor_total) as faturamento_bruto
from pedidos;

-- 9. INNER JOIN: nome do produto e nome da sua categoria
select p.nome as produto, c.nome as categoria
from produtos p
inner join categorias c on c.id_categoria = p.id_categoria;

-- 10. INNER JOIN com filtro: pedidos da cliente Ana Silva
select p.id_pedido, p.status, p.valor_total
from pedidos p
inner join clientes c on c.id_cliente = p.id_cliente
where c.nome = 'Ana Silva';