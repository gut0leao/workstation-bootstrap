# Roadmap

## Fase 1 — Estrutura e documentação

- Criar estrutura inicial do projeto.
- Criar README.
- Criar AGENTS.md.
- Criar documentos de visão, requisitos, arquitetura e decisões.
- Definir contrato de plataformas em `docs/platforms.md`.

## Fase 2 — Bootstrap Windows mínimo

- Implementar `install.ps1` remoto.
- Implementar `bootstrap.ps1`.
- Verificar Windows 11, PowerShell, admin e winget.
- Instalar WezTerm e VS Code.
- Instalar apps Windows declarados em `packages/windows.json` com `DryRun` e idempotência.

## Fase 3 — WSL e Ubuntu

- Instalar/ativar WSL2.
- Instalar Ubuntu.
- Validar `wsl --status` e `wsl -l -v`.
- Gerar `.wslconfig`.

## Fase 4 — Bootstrap Ubuntu no WSL

- Instalar pacotes Ubuntu.
- Configurar zsh.
- Instalar/configurar Starship.
- Instalar/configurar ferramentas modernas.

## Fase 5 — Export

- Implementar `-Export`.
- Exportar configurações atuais.
- Exportar lista de extensões VS Code.
- Exportar versões instaladas.
- Registrar host e ambiente Linux na exportação.
- Registrar artefatos gerenciados pelo projeto para uso futuro pelo reset.

## Fase 6 — Reset controlado para retestes

- Implementar `-Reset`.
- Implementar `-ResetScope`.
- Implementar `-ConfirmDestructive`.
- Implementar `DryRun` para reset.
- Restaurar backups quando possível.
- Suportar reset de configurações.
- Suportar reset de distro WSL gerenciada para testes.
- Exibir resumo de ações executadas, ignoradas e pendentes.

## Fase 7 — Perfis

- Implementar perfis `personal`, `corporate` e `minimal`.
- Permitir habilitar/desabilitar ferramentas por perfil.
- Permitir distinguir recursos por host suportado.

## Fase 8 — Preparação para Ubuntu host

- Criar TODOs executáveis para `install.sh` e `bootstrap.sh`.
- Separar pacotes comuns Ubuntu dos pacotes específicos de WSL.
- Documentar diferenças entre Ubuntu/WSL e Ubuntu host.
- Definir validações manuais para Ubuntu host.

## Fase 9 — Ubuntu host nativo

- Implementar `install.sh`.
- Implementar `bootstrap.sh`.
- Instalar pacotes Ubuntu via `apt`.
- Aplicar zsh e Starship localmente.
- Instalar/configurar editor, terminal e fontes definidos para Linux.
- Implementar export Linux.
- Implementar reset Linux equivalente com escopos seguros.

## Fase 10 — Expansões futuras

- Docker Desktop ou Podman.
- GitHub CLI.
- PowerShell profile.
- SSH/GPG.
- DDEV.
- Node, PHP, Ruby, Python, Java.
- Terraform, kubectl, Helm.
- macOS.
