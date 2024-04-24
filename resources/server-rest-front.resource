*** Settings ***
Library    Browser
...        enable_presenter_mode=${true}
Library    FakerLibrary
Library    DateTime
Library    OperatingSystem

*** Variables ***
${BROWSER}           chromium
${HEADLESS}          ${false}    #true é usado para indicar que o teste deve ser executado em "modo headless". O modo headless permite que o navegador seja executado sem uma interface gráfica
${SITE_SERVE_REST}   https://front.serverest.dev/
${ENABLE_TRACING}    ${false}

*** Keywords ***

Abrir o navegador

    ${TRACE_NAME}      FakerLibrary.Uuid 4
    ${NOW}             Get Current Date     result_format=%d-%m-%Y_%H%M%S
    ${VIDEO_DIR}       Set Variable         ${OUTPUT_DIR}/evidencies/videos/${NOW}
    ${TRACE_DIR}       Set Variable         ${OUTPUT_DIR}/evidencies/traces/${NOW}/${TRACE_NAME}.zip
    ${RECORD_VIDEO}    Create Dictionary    dir=${VIDEO_DIR}    size={'width': 1200, 'height': 800}   


    New Browser    browser=${BROWSER}
    ...            headless=${HEADLESS}

    New Context    viewport={'width': 1200, 'height': 800}
    ...            tracing=${TRACE_DIR}
    ...            recordVideo=${RECORD_VIDEO}

Ir para o site Serve Rest Front
    New Page       url=${SITE_SERVE_REST}
    ${title}       Get Title  ==  Front - ServeRest
    Log  ${title}

Preencher os dados do novo usuário e cadastrar
    # Record Selector
    # Click    css=.btn-link
    # Click    text="Cadastre-se"
    Click                css=a[data-testid='cadastrar']
    ${EMAIL}             FakerLibrary.Email
    Set Test Variable    ${EMAIL}
    Fill Text            css=input[data-testid='nome']       Jeferson Rauer
    Fill Text            css=input[data-testid='email']      ${EMAIL}
    Fill Text            css=input[data-testid='password']   123456
    Check Checkbox       css=input[data-testid='checkbox']
    Click                xpath=//*[@id="root"]//button >> text="Cadastrar"

Conferir usuário cadastrado com sucesso
    Wait For Elements State    h1   visible
    Get Text                   h1  ==  Bem Vindo Jeferson Rauer
    Get Element States         css=button[data-testid='logout']  validate  value & visible

Cadastrar novo usuário
    Abrir o navegador
    Ir para o site Serve Rest Front
    Preencher os dados do novo usuário e cadastrar
    Conferir usuário cadastrado com sucesso

Acessar a Lista de usuários
#    ${NOW2}             Get Current Date       result_format=%d-%m-%Y_%H%M%S
    Click                     css=a[data-testid='listarUsuarios']
#    Take Screenshot    filename=${OUTPUT_DIR}/evidencies/screenshot/Lista_usuarios/${NOW2}/lista_usuarios.png       fullPage=${true}    

Conferir que o usuário aparece na listagem
    Set Suite Variable     ${EMAIL}
    ${NOW3}               Get Current Date       result_format=%d-%m-%Y_%H%M%S
    ${elemento}           Get Table Cell Element    css=table    "Nome"    "${EMAIL}"
    ${usuario_nome}       Get Text   ${elemento}  ==  Jeferson Rauer
    Highlight Elements    ${elemento}
    Take Screenshot       filename=${OUTPUT_DIR}/evidencies/screenshot/${NOW3}/confere_usuario.png       fullPage=${true}    

Cadastrar um novo produto
  Click              css=a[data-testid='cadastrarProdutos']
  ${NOME_PRODUTO}    FakerLibrary.Word
  Set Test Variable  ${NOME_PRODUTO}
  Fill Text          css=input[data-testid='nome']          ${NOME_PRODUTO}
  Fill Text          css=input[data-testid='preco']         10
  Fill Text          css=textarea[data-testid='descricao']  Produto Teste Robot Framework
  Fill Text          css=input[data-testid='quantity']      5
  Click              text="Cadastrar"

Conferir que o produto aparece na listagem
  ${elemento}   Get Table Cell Element    css=table    "Descrição"    "${NOME_PRODUTO}"
  ${descricao}  Get Text  ${elemento}  ==  Produto Teste Robot Framework
  Highlight Elements      ${elemento}
  Take Screenshot         fullPage=${true}

Criar usuario via API
    ${EMAIL}    FakerLibrary.Email
    Set Suite Variable    ${EMAIL}
    ${resposta}    Http    url=https://serverest.dev/usuarios
    ...    method=POST
    ...    body={"nome": "Jeferson Rauer","email": "${EMAIL}","password": "123456","administrador": "true"}

    Should Be Equal As Integers    ${resposta["status"]}    201

Logar com o usuario cadastrado via API
    ${resposta}    Http    url=https://serverest.dev/login
    ...    method=POST
    ...    body={"email": "${EMAIL}","password": "123456"}

    Should Be Equal As Integers    ${resposta["status"]}    200
#Para pegar as chaves e valores: ir na pagina, dar F12, ir em Application e em "Local Storage"
    LocalStorage Set Item    serverest/userNome     Jeferson Rauer    
    LocalStorage Set Item    serverest/userEmail    ${EMAIL}
    LocalStorage Set Item    serverest/userToken    ${resposta["body"]["authorization"]}

    Go To    url=https://front.serverest.dev/admin/home

Cadastrar Usuário e Logar
    New Browser
    New Page      url=${SITE_SERVE_REST}
    Criar usuario via API
    Logar com o usuario cadastrado via API
    ${STORAGE_FILE}  Save Storage State
    Set Suite Variable  ${STORAGE_FILE}

Abrir o Site Serve Rest Front Logado
    New Browser    browser=${BROWSER}
    ...            headless=${HEADLESS}
    New Context    viewport={'width': 1200, 'height': 800}
    ...            storageState=${STORAGE_FILE}
    New Page       url=https://front.serverest.dev/admin/home
    Get Text       h1  ==  Bem Vindo Jeferson Rauer
    Take Screenshot
