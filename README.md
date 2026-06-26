# Workstation Bootstrap

**Workstation Bootstrap** é um projeto de *Infrastructure as Code (IaC)* para estações de trabalho de desenvolvimento.

O objetivo é permitir que uma máquina nova seja provisionada de forma reproduzível, segura e modular, transformando a configuração da workstation em código versionado.

A primeira plataforma alvo é:

- Windows 11;
- WSL2;
- Ubuntu;
- WezTerm;
- VS Code;
- zsh;
- Starship;
- ferramentas modernas de terminal.

## Objetivo

Configurar uma workstation de desenvolvimento com o menor número possível de comandos, instalando e configurando componentes no host Windows e no Ubuntu/WSL.

O projeto deve permitir:

- instalação remota sem clone prévio;
- instalação após clone manual;
- execução idempotente;
- backup antes de sobrescrever configurações;
- perfis de instalação;
- exportação da configuração atual da workstation;
- inclusão e remoção simples de ferramentas.

## Uso rápido futuro

Quando o projeto estiver implementado, o uso rápido esperado será:

```powershell
irm https://raw.githubusercontent.com/thefordexter/workstation-bootstrap/main/install.ps1 | iex
```

## Uso recomendado futuro

```powershell
irm https://raw.githubusercontent.com/thefordexter/workstation-bootstrap/main/install.ps1 -OutFile install.ps1
notepad install.ps1
.\install.ps1
```

## Uso após clone

```powershell
git clone https://github.com/thefordexter/workstation-bootstrap.git
cd workstation-bootstrap
.\bootstrap.ps1
```

## Arquitetura geral

```text
Windows 11 host
│
├── PowerShell bootstrap
├── WSL2
├── Ubuntu
├── WezTerm
├── VS Code
├── Nerd Fonts
└── .wslconfig

Ubuntu / WSL
│
├── zsh
├── Starship
├── eza
├── zoxide
├── fzf
├── bat
├── ripgrep
├── fd
├── btop
├── direnv
└── ferramentas de desenvolvimento
```

## Documentação

- [`AGENTS.md`](AGENTS.md): instruções para agentes de IA.
- [`docs/vision.md`](docs/vision.md): visão e filosofia do projeto.
- [`docs/requirements.md`](docs/requirements.md): requisitos funcionais e técnicos.
- [`docs/architecture.md`](docs/architecture.md): arquitetura planejada.
- [`docs/roadmap.md`](docs/roadmap.md): evolução futura.
- [`docs/decisions.md`](docs/decisions.md): decisões arquiteturais.
- [`docs/tools.md`](docs/tools.md): ferramentas previstas e dicas de uso.
- [`docs/troubleshooting.md`](docs/troubleshooting.md): problemas comuns.
- [`docs/profiles.md`](docs/profiles.md): perfis de instalação.

## Primeira implementação esperada

A primeira versão funcional deve implementar:

1. `install.ps1` para instalação remota.
2. `bootstrap.ps1` como orquestrador principal.
3. Verificações do Windows 11, PowerShell, admin, winget e WSL.
4. Instalação/configuração do WSL2 e Ubuntu.
5. Geração de `.wslconfig` baseada no hardware.
6. Instalação do WezTerm e VS Code.
7. Instalação de JetBrainsMono Nerd Font.
8. Configuração do WezTerm usando `default_prog` com `wsl.exe -d Ubuntu --cd ~`, além de menu/atalhos para PowerShell, CMD e Ubuntu.
9. Execução do bootstrap Linux dentro do Ubuntu.
10. Instalação/configuração de zsh, Starship e ferramentas de terminal.

## Validações esperadas

No Windows:

```powershell
wsl -l -v
wsl --status
wezterm --version
code --version
```

No Ubuntu/WSL:

```bash
echo $SHELL
zsh --version
starship --version
eza --version
zoxide --version
fzf --version
bat --version || batcat --version
rg --version
fd --version || fdfind --version
btop --version
direnv --version
```


## Configuração inicial incluída neste scaffold

Este pacote inicial já inclui os arquivos de configuração que foram validados manualmente:

- `config/wezterm/wezterm.lua`: configuração do WezTerm usando `default_prog` com `wsl.exe`, tema Tokyo Night, Acrylic, JetBrainsMono Nerd Font, launch menu e atalhos para PowerShell, CMD e Ubuntu.
- `config/zsh/.zshrc`: zsh limpo, sem Oh My Zsh, com histórico, autocomplete, aliases e integração condicional com zoxide, direnv e Starship.
- `config/starship/starship.toml`: prompt minimalista e contextual para Git, Python, Node, PHP, Ruby, Docker e duração de comandos.

## Publicação no GitHub

Este repositório será publicado manualmente no GitHub a partir da árvore local.

O repositório público esperado é:

```text
https://github.com/thefordexter/workstation-bootstrap
```

O branch principal esperado é `main`.
