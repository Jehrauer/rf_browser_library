*** Settings ***
Resource          ../resources/server-rest-front.resource
Suite Setup       Cadastrar Usuário e Logar
Suite Teardown    Close Browser    ALL


*** Test Cases ***
Login com sucesso Server Rest front
    Abrir o navegador
    Ir para o site Serve Rest Front
    Preencher os dados do novo usuário e cadastrar
    Conferir usuário cadastrado com sucesso

Conferir se o novo usuário é mostrado na listagem de usuários
    Abrir o Site Serve Rest Front Logado
    Acessar a Lista de usuários
    Conferir que o usuário aparece na listagem

Cadastro e Consulta de Produtos
    Abrir o Site Serve Rest Front Logado
    Cadastrar um novo produto
    Conferir que o produto aparece na listagem

Cadastrando usuario via HTTP
    Abrir o navegador
    Ir para o site Serve Rest Front
    Criar usuario via API    #via "Back-end" do site (Swagger API) -> https://serverest.dev/#/Usu%C3%A1rios/post_usuarios
    Logar com o usuario cadastrado via API

Cadastrar usuario usando o Storage Armazenando no Contexto
    Abrir o Site Serve Rest Front Logado
    Acessar a Lista de usuários