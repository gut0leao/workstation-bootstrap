# Roadmap

## Fase 1 — Estrutura e documentação

- Criar estrutura inicial do projeto.
- Criar README.
- Criar AGENTS.md.
- Criar documentos de visão, requisitos, arquitetura e decisões.

## Fase 2 — Bootstrap Windows mínimo

- Implementar `install.ps1` remoto.
- Implementar `bootstrap.ps1`.
- Verificar Windows 11, PowerShell, admin e winget.
- Instalar WezTerm e VS Code.

## Fase 3 — WSL e Ubuntu

- Instalar/ativar WSL2.
- Instalar Ubuntu.
- Validar `wsl --status` e `wsl -l -v`.
- Gerar `.wslconfig`.

## Fase 4 — Bootstrap Ubuntu

- Instalar pacotes Ubuntu.
- Configurar zsh.
- Instalar/configurar Starship.
- Instalar/configurar ferramentas modernas.

## Fase 5 — Export

- Implementar `-Export`.
- Exportar configurações atuais.
- Exportar lista de extensões VS Code.
- Exportar versões instaladas.

## Fase 6 — Perfis

- Implementar perfis `personal`, `corporate` e `minimal`.
- Permitir habilitar/desabilitar ferramentas por perfil.

## Fase 7 — Expansões futuras

- Docker Desktop ou Podman.
- GitHub CLI.
- PowerShell profile.
- SSH/GPG.
- DDEV.
- Node, PHP, Ruby, Python, Java.
- Terraform, kubectl, Helm.
- Suporte parcial a Linux nativo.
- Suporte parcial a macOS.
