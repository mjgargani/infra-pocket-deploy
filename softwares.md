Segue abaixo a documentação detalhada em português brasileiro, em formato Markdown, explicando de forma formal e acessível (utilizando conceitos de "portugol" quando necessário) cada parte do script. Ao final, encontram-se exercícios de fixação com gabarito para auxiliar no aprendizado.

---

# Documentação do Script de Instalação, Configuração, TDD e Logs

Esta documentação tem o objetivo de explicar, de forma clara e detalhada, as etapas e funcionalidades do script utilizado para automatizar a instalação e configuração de um ambiente Windows. O script foi projetado para ser executado em uma instalação limpa do Windows, garantindo que todas as tarefas necessárias sejam realizadas sem depender de ajustes manuais no sistema, mesmo quando a política de execução de scripts está desabilitada.

> **Observação Importante:**  
> Em uma instalação padrão do Windows, a política de execução costuma estar definida como “Restricted”, o que impede a execução de scripts. Para contornar esse problema de forma automática, o script possui um trecho inicial que relança a si mesmo utilizando a opção `-ExecutionPolicy Bypass`. Assim, mesmo que o usuário pertença ao grupo Administradores, o script se reinicia com as permissões necessárias, evitando erros relacionados à política de execução.

---

## Índice

1. [Introdução](#introdução)
2. [Objetivos](#objetivos)
3. [Requisitos e Ambiente](#requisitos-e-ambiente)
4. [Estrutura Geral do Script](#estrutura-geral-do-script)
5. [Descrição Detalhada por Seção](#descrição-detalhada-por-seção)
   - [1. Autorreinício para Bypass da Execução de Scripts](#1-autorreinício-para-bypass-da-execução-de-scripts)
   - [2. Configuração Inicial e Log](#2-configuração-inicial-e-log)
   - [3. Checagem de Privilégios de Administrador](#3-checagem-de-privilégios-de-administrador)
   - [4. Bloco de Testes (TDD) com Pester](#4-bloco-de-testes-tdd-com-pester)
   - [5. Atualizações do Windows](#5-atualizações-do-windows)
   - [6. Instalação de Softwares via Winget](#6-instalação-de-softwares-via-winget)
   - [7. Configuração do MySQL](#7-configuração-do-mysql)
   - [8. Instalação e Configuração do WSL 2](#8-instalação-e-configuração-do-wsl-2)
   - [9. Configuração do Docker para Usuários Convidados](#9-configuração-do-docker-para-usuários-convidados)
   - [10. Instalação do RSAT para Integração com AD](#10-instalação-do-rsat-para-integração-com-ad)
   - [11. Fase Interativa: Renomeação, Configuração do Administrador e Demissão do Usuário Atual](#11-fase-interativa-renomeação-configuração-do-administrador-e-demissão-do-usuário-atual)
   - [12. Verificações Adicionais e Sumário](#12-verificações-adicionais-e-sumário)
   - [13. Prompt Final e Reinicialização do Sistema](#13-prompt-final-e-reinicialização-do-sistema)
7. [Exercícios de Fixação](#exercícios-de-fixação)
8. [Gabarito dos Exercícios](#gabarito-dos-exercícios)

---

## Introdução

Este script automatiza um conjunto de tarefas essenciais para a preparação de um ambiente Windows – desde a aplicação de atualizações, instalação de softwares, até a configuração de contas e ajustes de segurança. Além disso, integra práticas de TDD (Test-Driven Development) para validar a execução das funções principais, registrando os resultados e erros em logs específicos.

---

## Objetivos

- **Automatizar Atualizações e Instalações:**  
  Aplicar atualizações do Windows (incluindo opcionais), instalar softwares essenciais (via winget) e configurar ferramentas como MySQL, WSL 2 e Docker.
  
- **Configuração de Contas e Segurança:**  
  Renomear o computador, habilitar a conta Administrador (com senha que não expira) e rebaixar o usuário atual para o grupo “Guests”, aumentando a segurança do sistema.

- **Validação com TDD e Logs Detalhados:**  
  Utilizar o módulo Pester para realizar testes automáticos das funções do script e gerar logs detalhados de execução e erros (tanto de testes quanto de execução), facilitando a identificação e correção de problemas.

- **Preparação para Integração com Domínio AD:**  
  Instalar RSAT (Remote Server Administration Tools) para permitir a futura integração do ambiente a um domínio Active Directory.

---

## Requisitos e Ambiente

- **Sistema Operacional:** Windows 10 ou 11.
- **Permissões:** O script deve ser executado em uma sessão do PowerShell com privilégios de Administrador.
- **Módulos Necessários:** PSWindowsUpdate e Pester.
- **Ferramentas:** Windows Package Manager (winget).

---

## Estrutura Geral do Script

O script foi dividido em diversas seções, cada uma responsável por uma etapa do processo de configuração. Ressalta-se o bloco inicial de autorreinício para contornar a política de execução de scripts, que é essencial em instalações limpas do Windows.

---

## Descrição Detalhada por Seção

### 1. Autorreinício para Bypass da Execução de Scripts

**Objetivo:**  
Contornar a política “Restricted” (padrão em instalações limpas do Windows) relançando o script com o parâmetro `-ExecutionPolicy Bypass`.

**O que é feito:**  
Antes de qualquer outra operação, o script verifica se a política de execução atual é diferente de “Bypass”. Caso seja, ele se relança automaticamente com a opção correta, garantindo que o restante do código seja executado sem restrições.

**Pseudocódigo (Portugol):**
```
se (política de execução != "Bypass") então
    relançar o script com "-ExecutionPolicy Bypass"
    encerrar execução atual
fim se
```

---

### 2. Configuração Inicial e Log

**Objetivo:**  
Estabelecer a política de execução, iniciar a transcrição completa da sessão e definir funções para registro de mensagens (logs).

**O que é feito:**  
- Configura a política para permitir a execução.
- Inicializa arquivos de log (principal, de erros de execução e de erros TDD).
- Define funções para registrar mensagens com timestamp.

---

### 3. Checagem de Privilégios de Administrador

**Objetivo:**  
Garantir que o script seja executado com permissões elevadas, necessárias para realizar alterações no sistema.

**O que é feito:**  
Verifica se o usuário atual possui privilégios de Administrador. Se não, o script registra o erro e encerra.

**Pseudocódigo:**
```
se (usuário não for Administrador) então
    registrar erro e encerrar
fim se
```

---

### 4. Bloco de Testes (TDD) com Pester

**Objetivo:**  
Validar automaticamente o funcionamento das funções principais por meio de testes. Isso permite identificar e registrar falhas antes de executar as operações críticas.

**O que é feito:**  
- Verifica e instala (se necessário) o módulo Pester.
- Define testes para funções principais (como restrição de acesso ao RSAT, configuração de auto-login para o Guest, etc.) usando mocks.
- Se algum teste falhar, o erro é registrado em um log específico e o script é encerrado.

**Pseudocódigo:**
```
se (Pester não instalado) então
    instalar Pester
fim se
importar Pester
definir testes para funções principais (com mocks)
se (algum teste falhar) então
    registrar erro de TDD e encerrar
fim se
```

---

### 5. Atualizações do Windows

**Objetivo:**  
Aplicar atualizações do Windows (pré e pós-processo), incluindo as opcionais, sem que erros interrompam o fluxo do script.

**O que é feito:**  
- Importa o módulo PSWindowsUpdate.
- Busca por atualizações e as instala sem reinicializar imediatamente.
- Registra o status da operação.

**Pseudocódigo:**
```
tentar importar PSWindowsUpdate
se (atualizações encontradas) então
    instalar atualizações sem reinicialização imediata
senão
    registrar que não houve atualizações
fim se
```

---

### 6. Instalação de Softwares via Winget

**Objetivo:**  
Instalar softwares essenciais somente se estes ainda não estiverem presentes no sistema, garantindo idempotência.

**O que é feito:**  
- Define uma função que verifica se um software já está instalado.
- Caso não esteja, o software é instalado via winget.
- Uma lista de softwares é percorrida e cada item é processado.

**Pseudocódigo:**
```
para cada software na lista:
    se (software já instalado) então
        pular instalação
    senão
        instalar software via winget
fim para
```

---

### 7. Configuração do MySQL

**Objetivo:**  
Configurar o MySQL, definindo a senha do usuário “root”, se o executável estiver presente.

**O que é feito:**  
- Verifica se o arquivo `mysqladmin.exe` existe.
- Tenta definir a senha “1234” para o usuário root.
- Registra sucesso ou erro da operação.

**Pseudocódigo:**
```
se (mysqladmin.exe existir) então
    definir senha do root como '1234'
senão
    registrar que o MySQL não foi encontrado
fim se
```

---

### 8. Instalação e Configuração do WSL 2

**Objetivo:**  
Preparar o ambiente para o WSL 2, habilitando os recursos necessários e instalando o kernel atualizado.

**O que é feito:**  
- Habilita os recursos “Windows Subsystem for Linux” e “Virtual Machine Platform”.
- Baixa e instala o kernel do WSL 2.
- Define o WSL 2 como versão padrão.

**Pseudocódigo:**
```
habilitar recursos WSL e Virtual Machine Platform
baixar e instalar atualização do kernel WSL 2
definir WSL 2 como padrão
```

---

### 9. Configuração do Docker para Usuários Convidados

**Objetivo:**  
Configurar o Docker para que usuários do tipo “Guest” possam utilizar contêineres de forma controlada.

**O que é feito:**  
- Adiciona os usuários “Guest” ao grupo “docker-users”.
- Atualiza o arquivo de configuração do Docker para incluir uma opção de limpeza automática dos contêineres de usuários convidados.

**Pseudocódigo:**
```
para cada usuário do tipo Guest:
    adicionar ao grupo docker-users
atualizar configuração do Docker para limpar contêineres de convidados
```

---

### 10. Instalação do RSAT para Integração com AD

**Objetivo:**  
Instalar as ferramentas RSAT (Remote Server Administration Tools) para Active Directory, preparando o ambiente para integração futura a um domínio.

**O que é feito:**  
- Verifica se a capacidade RSAT para AD está disponível.
- Se não estiver instalada, tenta instalá-la.
- Registra o status da operação.

**Pseudocódigo:**
```
verificar disponibilidade do RSAT para AD
se (não instalado) então
    instalar RSAT para AD
fim se
```

---

### 11. Fase Interativa: Renomeação, Configuração do Administrador e Demissão do Usuário Atual

**Objetivo:**  
Realizar configurações interativas com o usuário, garantindo ajustes importantes na identidade do sistema e segurança das contas.

**O que é feito:**  
- **Renomeação do Computador:**  
  Solicita um novo nome e, se fornecido e diferente do atual, renomeia o computador.
- **Configuração da Conta Administrador:**  
  Habilita a conta Administrador (caso não esteja ativa) e solicita uma nova senha, definindo-a como não expirá.
- **Rebaixamento do Usuário Atual:**  
  Remove o usuário atual do grupo “Administrators” e o adiciona ao grupo “Guests”.

**Pseudocódigo:**
```
perguntar novo nome do computador
se (novo nome ≠ nome atual) então
    renomear computador
fim se

habilitar conta Administrador e definir nova senha (não expira)

remover usuário atual do grupo Administrators
adicionar usuário atual ao grupo Guests
```

---

### 12. Verificações Adicionais e Sumário

**Objetivo:**  
Realizar verificações extras para confirmar que as configurações críticas foram aplicadas corretamente e compilar um resumo das tarefas realizadas.

**O que é feito:**  
- Verifica se a conta Administrador está habilitada e com senha configurada para não expirar.
- Verifica se o usuário atual pertence ao grupo “Guests”.
- Registra um sumário detalhado de cada etapa.

**Pseudocódigo:**
```
verificar configurações do Administrador
verificar que o usuário atual está no grupo Guests
compilar e registrar um sumário das tarefas executadas
```

---

### 13. Prompt Final e Reinicialização do Sistema

**Objetivo:**  
Exibir ao usuário um resumo das operações realizadas e solicitar confirmação para reinicializar o sistema, permitindo que as atualizações sejam aplicadas por completo.

**O que é feito:**  
- Mostra um resumo das tarefas concluídas.
- Pergunta se o sistema pode ser reiniciado.
- Se confirmado, reinicia o computador; caso contrário, encerra o script.

**Pseudocódigo:**
```
mostrar resumo das tarefas
perguntar se deseja reiniciar o sistema
se (resposta afirmativa) então
    reiniciar computador
senão
    encerrar script
fim se
```

---

## Exercícios de Fixação

### Exercício 1: Política de Execução de Scripts  
**Pergunta:** Por que é necessário que o script se relance com a opção `-ExecutionPolicy Bypass` em uma instalação limpa do Windows?  
**Dica:** Considere a política “Restricted” que vem por padrão.

---

### Exercício 2: Função de Verificação de Instalação  
**Pergunta:** Explique a importância da função `Is-SoftwareInstalled` antes de executar a instalação de um software.  
**Dica:** Pense em termos de idempotência e eficiência.

---

### Exercício 3: TDD com Pester  
**Pergunta:** O que é TDD e como o módulo Pester contribui para a qualidade do script?  
**Dica:** Considere a abordagem de escrever testes antes do código.

---

### Exercício 4: Configurações Interativas  
**Pergunta:** Quais são os três principais ajustes interativos realizados pelo script e qual a finalidade de cada um?  
**Dica:** Considere as etapas de renomeação do computador, configuração da conta Administrador e demissão do usuário atual.

---

## Gabarito dos Exercícios

1. **Exercício 1:**  
   Em uma instalação limpa do Windows, a política de execução padrão é “Restricted”, o que impede a execução de scripts. O relançamento com `-ExecutionPolicy Bypass` garante que o script possa rodar sem bloqueios, mesmo sem alterações manuais na política.

2. **Exercício 2:**  
   A função `Is-SoftwareInstalled` verifica se um software já está presente, evitando reinstalações desnecessárias. Isso torna o script idempotente e mais eficiente, evitando conflitos e consumo desnecessário de recursos.

3. **Exercício 3:**  
   TDD (Test-Driven Development) é uma metodologia de desenvolvimento onde os testes são escritos antes do código, garantindo que cada função atenda às especificações. O módulo Pester automatiza esses testes, permitindo identificar e corrigir falhas precocemente.

4. **Exercício 4:**  
   - **Renomeação do Computador:** Permite identificar melhor o dispositivo na rede.  
   - **Configuração da Conta Administrador:** Garante que a conta com maiores privilégios esteja ativa e segura (com senha que não expira).  
   - **Demissão do Usuário Atual:** Rebaixa o nível do usuário para “Guest”, aumentando a segurança ao limitar privilégios.

---

Esta documentação foi elaborada para que mesmo iniciantes possam compreender cada etapa do script e os conceitos utilizados. Experimente executar os exercícios e revise os conceitos para fixar o aprendizado. Caso haja dúvidas, revise os pseudocódigos e as descrições de cada seção para melhor entendimento.