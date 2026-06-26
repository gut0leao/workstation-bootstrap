# Requisitos

## Plataforma alvo inicial

- Windows 11.
- PowerShell como orquestrador principal.
- WSL2.
- Ubuntu mais recente disponível para WSL.

## Objetivos funcionais

O projeto deve automatizar:

1. Verificação dos pré-requisitos da máquina.
2. Ativação/instalação do WSL2.
3. Instalação do Ubuntu.
4. Configuração de `.wslconfig` baseada no hardware.
5. Instalação do WezTerm no Windows.
6. Configuração do WezTerm.
7. Instalação do VS Code no Windows.
8. Instalação da fonte JetBrainsMono Nerd Font.
9. Instalação do zsh no Ubuntu.
10. Configuração do zsh.
11. Instalação do Starship.
12. Configuração do Starship.
13. Instalação das ferramentas modernas de terminal.
14. Exportação das configurações atuais.

## Ferramentas Windows

Lista inicial em `packages/windows.json`:

- WezTerm;
- Visual Studio Code;
- GitHub CLI, opcional;
- Git for Windows, opcional.

## Pacotes Ubuntu

Lista inicial em `packages/ubuntu.txt`:

- zsh;
- git;
- curl;
- wget;
- unzip;
- build-essential;
- ca-certificates;
- software-properties-common;
- eza;
- zoxide;
- fzf;
- bat;
- ripgrep;
- fd-find;
- btop;
- direnv.

## Parâmetros esperados

`bootstrap.ps1` deve aceitar:

```powershell
-DryRun
-SkipWSL
-SkipWindowsApps
-SkipUbuntuPackages
-Export
-Profile personal|corporate|minimal
```

## Segurança

- Não sobrescrever arquivos sem backup.
- Não executar comandos destrutivos sem confirmação explícita.
- Não imprimir credenciais.
- Implementar modo `-DryRun`.
- Tratar erros claramente.

## Backups

Antes de substituir arquivos, criar backup com timestamp.

Exemplos:

```text
.zshrc.backup-20260626-153000
starship.toml.backup-20260626-153000
.wezterm.lua.backup-20260626-153000
.wslconfig.backup-20260626-153000
```

## Resultado esperado

Ao final, abrir o WezTerm no Windows deve levar diretamente ao Ubuntu/WSL usando zsh com Starship configurado, fonte Nerd Font e ferramentas modernas instaladas.
