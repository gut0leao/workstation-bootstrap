# Visão

O `workstation-bootstrap` é um projeto de *Infrastructure as Code* para workstations de desenvolvimento.

A ideia central é tratar a configuração da máquina de trabalho como código versionado, auditável e reproduzível.

## Problema

Configurar uma máquina nova de desenvolvimento normalmente envolve muitos passos manuais:

- ativar recursos do Windows;
- instalar WSL;
- instalar Ubuntu;
- configurar limites de RAM e CPU;
- instalar terminal;
- configurar fontes;
- instalar editor;
- instalar shell;
- configurar prompt;
- instalar utilitários;
- recriar aliases e preferências.

Esse processo é repetitivo, sujeito a esquecimento e difícil de auditar.

## Solução

Este projeto deve permitir que uma workstation nova seja configurada com o menor número possível de comandos, mantendo todas as decisões em arquivos versionados.

## Filosofia

- Simplicidade antes de automação excessiva.
- Idempotência antes de velocidade.
- Segurança antes de conveniência.
- Modularidade antes de scripts monolíticos.
- Clareza antes de abstrações complexas.

## Escopo inicial

A primeira versão tem foco em Windows 11 com WSL2 e Ubuntu.

## Escopo futuro

O projeto pode evoluir para suportar:

- outros perfis de workstation;
- ambientes corporativos restritos;
- Linux nativo;
- macOS;
- Docker Desktop;
- Podman;
- GitHub CLI;
- PowerShell profile;
- SSH/GPG;
- linguagens e toolchains específicos.
