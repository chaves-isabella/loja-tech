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

-- ------------------------------------------------------------
-- 6. atualizar_preco_categoria
-- reajusta os preços dos produtos ativos de uma categoria.
-- percentual positivo = aumento (máximo 100%).
-- percentual negativo = desconto (máximo 50%).
-- percentual zero não é permitido.
-- retorna pelo out a quantidade de produtos alterados e uma mensagem.
-- registra a operação em log_operacoes.
-- ------------------------------------------------------------
drop procedure if exists atualizar_preco_categoria;

delimiter //
create procedure atualizar_preco_categoria(
    in p_id_categoria int,
    in p_percentual decimal(5,2),
    out p_qtd_alterados int,
    out p_mensagem varchar(255)
)
begin
    declare v_categoria_existe int default 0;

    set p_qtd_alterados = 0;

    -- validação 1: a categoria existe?
    select count(*) into v_categoria_existe
    from categorias
    where id_categoria = p_id_categoria;

    if v_categoria_existe = 0 then
        set p_mensagem = 'ERRO: Categoria não encontrada.';

    -- validação 2: percentual diferente de zero
    elseif p_percentual = 0 then
        set p_mensagem = 'ERRO: O percentual deve ser diferente de zero.';

    -- validação 3: limite de desconto
    elseif p_percentual < -50 then
        set p_mensagem = 'ERRO: O desconto máximo permitido é de 50%.';

    -- validação 4: limite de aumento
    elseif p_percentual > 100 then
        set p_mensagem = 'ERRO: O aumento máximo permitido é de 100%.';

    -- tudo válido: aplica o reajuste
    else
        update produtos
        set preco = round(preco * (1 + p_percentual / 100), 2)
        where id_categoria = p_id_categoria
          and ativo = true;

        set p_qtd_alterados = row_count();

        insert into log_operacoes (tabela_afetada, operacao, descricao)
        values ('produtos', 'UPDATE_PRECO',
                concat('Categoria #', p_id_categoria,
                       ' | Percentual: ', p_percentual, '%',
                       ' | Produtos alterados: ', p_qtd_alterados));

        set p_mensagem = concat('Sucesso: ', p_qtd_alterados,
                                ' produto(s) reajustado(s).');
    end if;
end //
delimiter ;

-- ------------------------------------------------------------
-- 7. consultar_extrato_cliente
-- monta o extrato de um cliente em três result sets:
-- 1) dados cadastrais, 2) lista de pedidos, 3) resumo financeiro.
-- se o cliente não existir, retorna apenas uma mensagem de erro.
-- o resumo considera apenas pedidos não cancelados.
-- ------------------------------------------------------------
drop procedure if exists consultar_extrato_cliente;

delimiter //
create procedure consultar_extrato_cliente(
    in p_id_cliente int
)
begin
    declare v_existe int default 0;

    -- verifica se o cliente existe
    select count(*) into v_existe
    from clientes
    where id_cliente = p_id_cliente;

    if v_existe = 0 then
        select 'ERRO: Cliente não encontrado.' as mensagem;
    else
        -- result set 1: dados do cliente
        select nome, email, telefone, criado_em as data_cadastro
        from clientes
        where id_cliente = p_id_cliente;

        -- result set 2: todos os pedidos do cliente
        select id_pedido as numero_pedido, data_pedido, status, valor_total
        from pedidos
        where id_cliente = p_id_cliente
        order by data_pedido;

        -- result set 3: resumo financeiro (sem pedidos cancelados)
        select
            count(*) as total_pedidos,
            ifnull(sum(valor_total), 0) as valor_total_gasto,
            ifnull(round(avg(valor_total), 2), 0) as ticket_medio,
            max(data_pedido) as ultimo_pedido
        from pedidos
        where id_cliente = p_id_cliente
          and status <> 'cancelado';
    end if;
end //
delimiter ;

show procedure status where db = 'loja_tech';
