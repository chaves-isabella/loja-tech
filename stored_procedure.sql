use loja_tech;

-- ------------------------------------------------------------
-- 1. listar_categorias_ativas
-- lista todas as categorias ativas (id, nome e descrição),
-- em ordem alfabética pelo nome.
-- ------------------------------------------------------------
drop procedure if exists listar_categorias_ativas;

delimiter //
create procedure listar_categorias_ativas()
begin
    select id_categoria, nome, descricao
    from categorias
    where ativo = true
    order by nome;
end //
delimiter ;

-- ------------------------------------------------------------
-- 2. buscar_pedidos_por_status
-- recebe um status e lista os pedidos com esse status
-- (id do pedido, id do cliente, data e valor total).
-- ------------------------------------------------------------
drop procedure if exists buscar_pedidos_por_status;

delimiter //
create procedure buscar_pedidos_por_status(
    in p_status varchar(20)
)
begin
    select id_pedido, id_cliente, data_pedido, valor_total
    from pedidos
    where status = p_status;
end //
delimiter ;

-- ------------------------------------------------------------
-- 3. inserir_categoria
-- insere uma nova categoria com nome e descrição.
-- as colunas ativo e criado_em usam os valores padrão da tabela.
-- ------------------------------------------------------------
drop procedure if exists inserir_categoria;

delimiter //
create procedure inserir_categoria(
    in p_nome varchar(100),
    in p_descricao text
)
begin
    insert into categorias (nome, descricao)
    values (p_nome, p_descricao);
end //
delimiter ;

-- ------------------------------------------------------------
-- 4. atualizar_telefone_cliente
-- atualiza o telefone do cliente informado pelo id.
-- ------------------------------------------------------------
drop procedure if exists atualizar_telefone_cliente;

delimiter //
create procedure atualizar_telefone_cliente(
    in p_id_cliente int,
    in p_telefone varchar(15)
)
begin
    update clientes
    set telefone = p_telefone
    where id_cliente = p_id_cliente;
end //
delimiter ;

-- ------------------------------------------------------------
-- 5. contar_produtos_categoria
-- conta quantos produtos existem em uma categoria.
-- o total é devolvido pelo parâmetro out p_total.
-- ------------------------------------------------------------
drop procedure if exists contar_produtos_categoria;

delimiter //
create procedure contar_produtos_categoria(
    in p_id_categoria int,
    out p_total int
)
begin
    select count(*)
    into p_total
    from produtos
    where id_categoria = p_id_categoria;
end //
delimiter ;

show procedure status where db = 'loja_tech';