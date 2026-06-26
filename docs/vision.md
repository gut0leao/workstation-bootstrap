# Visão

O `workstation-bootstrap` é um projeto de *Infrastructure as Code* para workstations de desenvolvimento.

A ideia central é tratar a configuração da máquina de trabalho como código versionado, auditável e reproduzível, sem amarrar o conceito do projeto a um único sistema operacional host.

## Problema

Configurar uma máquina nova de desenvolvimento normalmente envolve muitos passos manuais:

- validar o sistema operacional host;
- instalar gerenciadores de pacotes;
- instalar terminal, editor e fontes;
- instalar ou preparar um ambiente Linux;
- configurar shell;
- configurar prompt;
- instalar utilitários;
- recriar aliases e preferências;
- ajustar integrações entre host, terminal e editor.

No Windows 11, isso inclui ativar recursos do Windows, instalar WSL2, instalar Ubuntu e configurar limites de RAM/CPU via `.wslconfig`.

No Ubuntu host nativo, esses passos serão diferentes: não haverá WSL, `.wslconfig` nem `winget`, mas ainda haverá pacotes, shell, prompt, editor, terminal e configurações do usuário.

## Solução

Este projeto deve permitir que uma workstation nova seja configurada com o menor número possível de comandos, mantendo todas as decisões em arquivos versionados.

A solução deve separar:

- o host onde o bootstrap começa;
- os ambientes Linux gerenciados pelo bootstrap;
- ferramentas compartilhadas entre plataformas;
- ferramentas específicas de cada host.

## Filosofia

- Simplicidade antes de automação excessiva.
- Idempotência antes de velocidade.
- Segurança antes de conveniência.
- Modularidade antes de scripts monolíticos.
- Clareza antes de abstrações complexas.
- Portabilidade planejada antes de generalização prematura.

## Escopo inicial

A primeira versão implementa apenas:

- Windows 11 como host;
- PowerShell como orquestrador do host Windows;
- WSL2;
- Ubuntu dentro do WSL como ambiente Linux de desenvolvimento.

## Escopo futuro

O projeto deve deixar TODOs e contratos claros para evoluir para:

- Ubuntu nativo como host;
- outros perfis de workstation;
- ambientes corporativos restritos;
- Docker Desktop ou Podman;
- GitHub CLI;
- PowerShell profile;
- SSH/GPG;
- linguagens e toolchains específicos;
- macOS, apenas depois que Windows e Ubuntu host estiverem bem definidos.
