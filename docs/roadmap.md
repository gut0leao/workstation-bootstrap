# Roadmap

## Estado atual

As fases 1 a 6 estão implementadas para o escopo Windows 11 + WSL2 + Ubuntu. A fase 7 está parcial: os perfis `personal`, `corporate` e `minimal` são aceitos, validados e registrados no manifesto, mas ainda não alteram listas de ferramentas ou capacidades. As fases 8 a 10 continuam planejadas.

## Fase 1 — Estrutura e documentação

- Implementado: criar estrutura inicial do projeto.
- Implementado: criar README.
- Implementado: criar AGENTS.md.
- Implementado: criar documentos de visão, requisitos, arquitetura e decisões.
- Implementado: definir contrato de plataformas em `docs/platforms.md`.

## Fase 2 — Bootstrap Windows mínimo

- Implementado: `install.ps1` remoto, incluindo execução via `irm ... | iex`.
- Implementado: `bootstrap.ps1`.
- Implementado: verificar Windows 11, PowerShell, admin e winget.
- Implementado: instalar WezTerm e VS Code.
- Implementado: instalar apps Windows declarados em `packages/windows.json` com `DryRun` e idempotência.
- Implementado: aplicar configuração versionada do WezTerm com backup e idempotência.
- Implementado: instalar JetBrainsMono Nerd Font quando ausente.
- Implementado: instalar extensões VS Code declaradas com `DryRun` e idempotência.

## Fase 3 — WSL e Ubuntu

- Implementado: instalar/ativar WSL2 por meio de `wsl --install -d <distro>` quando a distro alvo não existe.
- Implementado: instalar Ubuntu no WSL quando ausente.
- Implementado: validar disponibilidade de `wsl`.
- Implementado: gerar `.wslconfig`.
- Implementado: criar backup antes de substituir `.wslconfig`.
- Implementado: não recriar nem assumir ownership de distros WSL pré-existentes.

## Fase 4 — Bootstrap Ubuntu no WSL

- Implementado: instalar pacotes Ubuntu quando `sudo` não interativo está disponível.
- Implementado: configurar zsh.
- Implementado: instalar/configurar Starship.
- Implementado: validar ferramentas modernas.
- Implementado: chamar bootstrap Ubuntu a partir do PowerShell no host Windows.
- Implementado: evitar prompts interativos de `sudo` em automação.

## Fase 5 — Export

- Implementado: `-Export`.
- Implementado: exportar configurações atuais.
- Implementado: exportar lista de extensões VS Code.
- Implementado: exportar snapshot do host, lista `winget`, status/lista WSL e configurações conhecidas.
- Implementado: registrar artefatos gerenciados pelo projeto para uso pelo reset.
- Implementado: exportar estado e configurações para `exports/<timestamp>/`.

## Fase 6 — Reset controlado para retestes

- Implementado: `-Reset`.
- Implementado: `-ResetScope`.
- Implementado: `-ConfirmDestructive`.
- Implementado: `DryRun` para reset.
- Implementado: restaurar backups quando possível.
- Implementado: reset de configurações.
- Implementado: reset de distro WSL gerenciada para testes.
- Implementado: reset de apps Windows gerenciados.
- Implementado: resumo de ações executadas, ignoradas e pendentes.
- Parcial: `UbuntuTools` apenas registra pendência conservadora; pacotes `apt` ainda não são removidos.

## Fase 7 — Perfis

- Parcial: aceitar e validar perfis `personal`, `corporate` e `minimal`.
- Pendente: permitir habilitar/desabilitar ferramentas por perfil.
- Pendente: permitir distinguir recursos por host suportado.

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
