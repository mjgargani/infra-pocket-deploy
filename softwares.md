# Documentação do Script de Instalação, Configuração, TDD e Logs

Esta documentação tem o objetivo de explicar de forma clara e detalhada cada parte do script, utilizando uma linguagem formal e acessível para iniciantes. Sempre que necessário, utilizaremos conceitos básicos (como pseudocódigo "portugol") para facilitar o entendimento. Ao final, serão propostos exercícios de fixação com um gabarito separado.

---

## Índice

1. [Introdução](#introdução)
2. [Objetivos](#objetivos)
3. [Requisitos e Ambiente](#requisitos-e-ambiente)
4. [Visão Geral do Script](#visão-geral-do-script)
5. [Descrição Detalhada por Seção](#descrição-detalhada-por-seção)
    - [Configuração Inicial e Log](#configuração-inicial-e-log)
    - [Checagem de Privilégios de Administrador](#checagem-de-privilégios-de-administrador)
    - [Bloco de Testes (TDD) com Pester](#bloco-de-testes-tdd-com-pester)
    - [Atualizações do Windows](#atualizações-do-windows)
    - [Instalação de Softwares via Winget](#instalação-de-softwares-via-winget)
    - [Configuração do MySQL](#configuração-do-mysql)
    - [Instalação e Configuração do WSL 2](#instalação-e-configuração-do-wsl-2)
    - [Configuração do Docker para Usuários Convidados](#configuração-do-docker-para-usuários-convidados)
    - [Instalação do RSAT para Integração com AD](#instalação-do-rsat-para-integração-com-ad)
    - [Fase Interativa: Renomeação, Configuração do Administrador e Demissão do Usuário Atual](#fase-interativa-renomeação-configuração-do-administrador-e-demissão-do-usuário-atual)
    - [Verificações Adicionais e Sumário](#verificações-adicionais-e-sumário)
    - [Prompt Final e Reinicialização do Sistema](#prompt-final-e-reinicialização-do-sistema)
6. [Exercícios de Fixação](#exercícios-de-fixação)
7. [Gabarito dos Exercícios](#gabarito-dos-exercícios)

---

## Introdução

Este script automatiza um conjunto de tarefas essenciais para a preparação de um ambiente Windows, incluindo atualizações do sistema, instalação de softwares, configuração de contas de usuário e ajustes para futura integração em um domínio Active Directory (AD). Adicionalmente, incorpora uma abordagem de TDD (Test-Driven Development) utilizando o módulo Pester para garantir a qualidade e robustez das funções implementadas.

---

## Objetivos

- **Automatizar atualizações e instalações:** Aplicar atualizações do Windows, instalar softwares essenciais e configurar ferramentas como MySQL, WSL 2 e Docker.
- **Configuração de contas e segurança:** Renomear o computador, habilitar a conta Administrador (com senha que não expira) e rebaixar o usuário atual para o grupo "Guest".
- **TDD e logs detalhados:** Utilizar o Pester para criar testes automáticos (TDD) e gerar logs detalhados de execução e erros para melhoria contínua.
- **Preparação para ambiente AD:** Instalar RSAT (Remote Server Administration Tools) para futura integração em um domínio AD.

---

## Requisitos e Ambiente

- **Sistema Operacional:** Windows 10 ou 11.
- **Permissões:** O script deve ser executado em uma sessão do PowerShell com privilégios de Administrador.
- **Módulos necessários:** PSWindowsUpdate, Pester.
- **Ferramentas:** Windows Package Manager (winget).

---

## Visão Geral do Script

O script é dividido em várias etapas:

1. **Configuração Inicial:** Define a política de execução, inicializa logs e estabelece funções para registro de mensagens.
2. **Checagem de Administrador:** Verifica se o script está sendo executado com privilégios elevados.
3. **Bloco TDD (Test-Driven Development):** Utiliza o Pester para testar as funções principais.
4. **Atualizações do Windows:** Aplica atualizações (pré e pós) utilizando o módulo PSWindowsUpdate.
5. **Instalação de Softwares:** Verifica se os softwares estão instalados e, se não, os instala via winget.
6. **Configurações Específicas:** Configuração do MySQL, WSL 2, Docker e RSAT.
7. **Fase Interativa:** Solicita informações do usuário para renomear o computador, configurar a conta Administrador e ajustar a conta do usuário atual.
8. **Verificações Finais e Reinicialização:** Realiza verificações adicionais, compila um sumário das tarefas e pergunta se deseja reiniciar o sistema.

---

## Descrição Detalhada por Seção

### Configuração Inicial e Log

- **O que é feito:**  
  - Define a política de execução para permitir que o script seja executado.
  - Inicializa o sistema de logs (arquivo principal e arquivos de erro) e inicia uma transcrição completa da sessão.
  
- **Pseudocódigo (portugol):**
  ```
  definir política de execução como Bypass
  iniciar log e transcrição de sessão
  definir funções para registrar mensagens (INFO e ERROR)
  ```

### Checagem de Privilégios de Administrador

- **O que é feito:**  
  - Verifica se o usuário atual possui privilégios de Administrador. Se não, registra o erro e encerra o script.
  
- **Pseudocódigo:**
  ```
  se usuário não for Administrador:
      registrar erro e encerrar
  ```

### Bloco de Testes (TDD) com Pester

- **O que é feito:**  
  - Verifica se o módulo Pester está instalado; caso não esteja, tenta instalá-lo.
  - Define testes para funções principais (ex.: restrição de acesso ao RSAT, configuração de auto-login para o Guest, etc.) usando mocks.
  - Se algum teste falhar, registra o erro em um log específico e encerra o script.
  
- **Pseudocódigo:**
  ```
  se Pester não estiver instalado:
      instalar Pester
  importar Pester
  definir testes para as funções principais usando mocks
  se algum teste falhar:
      registrar erro de TDD e encerrar
  ```

### Atualizações do Windows

- **O que é feito:**  
  - Realiza atualizações do Windows antes e depois das principais tarefas do script, incluindo atualizações opcionais.
  - Caso a atualização falhe, o erro é registrado, mas o script continua a execução.
  
- **Pseudocódigo:**
  ```
  tentar instalar atualizações do Windows (incluir opcionais)
  se atualizações encontradas:
      instalar atualizações sem reinicialização imediata
  senão:
      registrar que nenhuma atualização foi encontrada
  ```

### Instalação de Softwares via Winget

- **O que é feito:**  
  - Define funções para verificar se um software já está instalado e, caso não esteja, instalá-lo via winget.
  - Uma lista de softwares é percorrida e cada software é instalado apenas se necessário (idempotência).
  
- **Pseudocódigo:**
  ```
  para cada software na lista:
      se software já instalado:
          pular instalação
      senão:
          instalar software via winget
  ```

### Configuração do MySQL

- **O que é feito:**  
  - Se o executável do MySQL existir, o script tenta configurar a senha do usuário "root".
  - Caso ocorra algum erro, este é registrado.
  
- **Pseudocódigo:**
  ```
  se mysqladmin.exe existir:
      definir senha do root como '1234'
  senão:
      registrar que o MySQL não foi encontrado
  ```

### Instalação e Configuração do WSL 2

- **O que é feito:**  
  - Habilita os recursos necessários do Windows para o WSL.
  - Baixa e instala o kernel do WSL 2 e define-o como padrão.
  
- **Pseudocódigo:**
  ```
  habilitar recursos WSL e Virtual Machine Platform
  baixar e instalar atualização do kernel WSL 2
  definir WSL 2 como padrão
  ```

### Configuração do Docker para Usuários Convidados

- **O que é feito:**  
  - Adiciona usuários do tipo "Guest" ao grupo "docker-users".
  - Atualiza a configuração do Docker para limpeza automática de contêineres de usuários convidados.
  
- **Pseudocódigo:**
  ```
  para cada usuário Guest:
      adicionar ao grupo docker-users
  atualizar arquivo de configuração do Docker com limpeza de contêineres de convidados
  ```

### Instalação do RSAT para Integração com AD

- **O que é feito:**  
  - Verifica se a capacidade RSAT (para Active Directory) está disponível e, se não estiver instalada, a instala.
  
- **Pseudocódigo:**
  ```
  verificar se RSAT para AD está disponível
  se não estiver instalado:
      instalar RSAT para AD
  ```

### Fase Interativa: Renomeação, Configuração do Administrador e Demissão do Usuário Atual

- **O que é feito:**  
  - Solicita ao usuário um novo nome para o computador e, se diferente do atual, o renomeia.
  - Habilita a conta Administrador (se não estiver habilitada) e define uma nova senha, garantindo que a senha não expire.
  - Remove o usuário atual do grupo Administradores e o adiciona ao grupo "Guests".
  
- **Pseudocódigo:**
  ```
  perguntar novo nome do computador
  se novo nome for diferente:
      renomear computador
  habilitar conta Administrador e definir nova senha (não expira)
  remover usuário atual do grupo Administradores e adicionar ao grupo Guests
  ```

### Verificações Adicionais e Sumário

- **O que é feito:**  
  - Realiza verificações extras para confirmar que:
    - A conta Administrador está habilitada e com senha que não expira.
    - O usuário atual foi corretamente movido para o grupo "Guests".
  - Compila um sumário das etapas realizadas, registrando o status de cada uma.
  
- **Pseudocódigo:**
  ```
  verificar configurações do Administrador
  verificar que usuário atual está no grupo Guests
  compilar resumo das tarefas executadas
  ```

### Prompt Final e Reinicialização do Sistema

- **O que é feito:**  
  - Exibe o sumário das tarefas para o usuário e solicita confirmação para reinicializar o sistema.
  - Se o usuário confirmar, o sistema é reinicializado; caso contrário, o script apenas encerra.
  
- **Pseudocódigo:**
  ```
  mostrar resumo das tarefas executadas
  perguntar se deseja reiniciar o sistema
  se sim:
      reiniciar
  senão:
      encerrar
  ```

---

## Exercícios de Fixação

### Exercício 1: Conceitos Básicos do Script
**Pergunta:** Explique, em suas próprias palavras, qual a importância da verificação de privilégios de Administrador no início do script.  
**Resposta Esperada:**  
A verificação de privilégios de Administrador é essencial para garantir que o script tenha permissão para executar operações sensíveis, como alterações no sistema, instalação de softwares e configuração de contas. Sem essas permissões, muitas das tarefas do script falhariam.

---

### Exercício 2: Função de Instalação de Software
**Pergunta:** Qual a vantagem de utilizar a função `Is-SoftwareInstalled` antes de instalar um software?  
**Resposta Esperada:**  
Utilizar a função `Is-SoftwareInstalled` permite que o script verifique se um software já está instalado, evitando instalações desnecessárias. Isso torna o script idempotente e otimizado para ser executado várias vezes sem causar conflitos ou redundâncias.

---

### Exercício 3: Bloco TDD com Pester
**Pergunta:** Por que o script utiliza o módulo Pester e o que significa "TDD" no contexto deste script?  
**Resposta Esperada:**  
O módulo Pester é utilizado para automatizar testes que verificam se as funções principais do script estão funcionando corretamente. TDD (Test-Driven Development) é uma abordagem de desenvolvimento que consiste em escrever testes antes do código, garantindo que cada parte funcione como esperado e permitindo a identificação de falhas precocemente.

---

### Exercício 4: Configuração Interativa
**Pergunta:** Quais são as três principais configurações interativas que o script solicita ao usuário e qual a finalidade de cada uma?  
**Resposta Esperada:**  
1. **Renomeação do computador:** Permite ao usuário definir um novo nome para o computador, facilitando a identificação em uma rede.
2. **Configuração da conta Administrador:** Habilita a conta Administrador e define uma nova senha que não expira, garantindo acesso administrativo seguro.
3. **Demissão do usuário atual para o grupo "Guests":** Remove o usuário atual do grupo Administradores e o adiciona ao grupo Guests, reforçando a segurança do sistema ao limitar privilégios.

---

## Gabarito dos Exercícios

1. **Exercício 1:**  
   A verificação de privilégios de Administrador é fundamental para que o script possa executar tarefas críticas, como instalação de softwares e modificações no sistema, que requerem permissões elevadas. Sem essa verificação, o script pode falhar ou não realizar as alterações desejadas.

2. **Exercício 2:**  
   A função `Is-SoftwareInstalled` permite verificar se um software já está presente no sistema, evitando reinstalações desnecessárias. Isso melhora a eficiência do script e previne possíveis conflitos decorrentes de instalações duplicadas.

3. **Exercício 3:**  
   O módulo Pester é utilizado para executar testes automatizados que garantem o funcionamento correto das funções do script. TDD (Test-Driven Development) é uma prática onde os testes são escritos antes do código, permitindo identificar erros de forma precoce e facilitando a manutenção.

4. **Exercício 4:**  
   - **Renomeação do computador:** Para que o computador tenha um nome identificável em redes, facilitando a gestão e o controle.
   - **Configuração da conta Administrador:** Garante que a conta de maior privilégio esteja ativa, com senha segura e sem expiração, garantindo acesso administrativo quando necessário.
   - **Demissão do usuário atual para o grupo "Guests":** Limita os privilégios do usuário atual para aumentar a segurança do sistema, garantindo que apenas as operações essenciais sejam realizadas com a conta de usuário não privilegiada.

---

Esta documentação foi elaborada para auxiliar na compreensão de cada etapa do script, permitindo que até mesmo iniciantes possam entender os conceitos e a lógica por trás das operações automatizadas. Sinta-se à vontade para revisar os exercícios e testar o script em um ambiente controlado para melhor aprendizado.