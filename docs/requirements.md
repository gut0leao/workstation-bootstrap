# Requisitos

## Contrato de plataforma

O projeto deve ser agnóstico no desenho, mas explícito no que está implementado.

### Implementado agora

- Host Windows 11.
- PowerShell como orquestrador do host Windows.
- WSL2.
- Ubuntu mais recente disponível para WSL.

### Planejado, não implementado

- Host Ubuntu nativo.
- Bash como orquestrador do host Ubuntu.
- Instalação local de pacotes, terminal, editor, fontes e configurações sem WSL.

## Objetivos funcionais atuais

No fluxo Windows 11 + WSL2 + Ubuntu, o projeto deve automatizar:

1. Verificação dos pré-requisitos da máquina.
2. Ativação/instalação do WSL2.
3. Instalação do Ubuntu no WSL.
4. Configuração de `.wslconfig` baseada no hardware.
5. Instalação do WezTerm no Windows.
6. Configuração do WezTerm.
7. Instalação do VS Code no Windows.
8. Instalação da fonte JetBrainsMono Nerd Font.
9. Execução do bootstrap Linux dentro do Ubuntu/WSL.
10. Instalação do zsh no Ubuntu.
11. Configuração do zsh.
12. Instalação do Starship.
13. Configuração do Starship.
14. Instalação das ferramentas modernas de terminal.
15. Exportação das configurações atuais.

## Objetivos funcionais futuros para Ubuntu host

TODO:

1. Criar instalador remoto `install.sh`.
2. Criar orquestrador de host Linux `bootstrap.sh`.
3. Detectar distribuição, versão e gerenciador de pacotes.
4. Suportar inicialmente Ubuntu LTS.
5. Instalar pacotes via `apt`.
6. Instalar/configurar terminal no host Linux, se aplicável.
7. Instalar/configurar VS Code ou alternativa definida.
8. Instalar/configurar fontes no Linux.
9. Aplicar as mesmas configurações compartilhadas de zsh e Starship.
10. Exportar configurações do host Ubuntu.

## Ferramentas do host Windows

Lista inicial em `packages/windows.json`:

- WezTerm;
- Visual Studio Code;
- GitHub CLI, opcional;
- Git for Windows, opcional.

## Pacotes Ubuntu

Lista inicial em `packages/ubuntu.txt`.

Esses pacotes são usados hoje dentro do Ubuntu/WSL. A lista deve continuar válida para Ubuntu host sempre que possível, mas pacotes específicos de WSL devem ser separados no futuro.

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

## Parâmetros esperados no Windows

`bootstrap.ps1` deve aceitar:

```powershell
-DryRun
-SkipWSL
-SkipWindowsApps
-SkipUbuntuPackages
-Export
-Profile personal|corporate|minimal
```

## Parâmetros futuros no Ubuntu host

TODO: `bootstrap.sh` deve aceitar equivalentes em Bash:

```bash
--dry-run
--skip-host-apps
--skip-ubuntu-packages
--export
--profile personal|corporate|minimal
```

## Segurança

- Não sobrescrever arquivos sem backup.
- Não executar comandos destrutivos sem confirmação explícita.
- Não imprimir credenciais.
- Implementar modo `DryRun`.
- Tratar erros claramente.
- Isolar ações específicas de cada host.

## Backups

Antes de substituir arquivos, criar backup com timestamp.

Exemplos:

```text
.zshrc.backup-20260626-153000
starship.toml.backup-20260626-153000
wezterm.lua.backup-20260626-153000
.wslconfig.backup-20260626-153000
```

## Resultado esperado atual

Ao final do fluxo Windows, abrir o WezTerm no Windows deve levar diretamente ao Ubuntu/WSL usando zsh com Starship configurado, fonte Nerd Font e ferramentas modernas instaladas.

## Resultado esperado futuro

TODO: ao final do fluxo Ubuntu host, abrir o terminal configurado no Ubuntu nativo deve usar zsh com Starship e as mesmas ferramentas modernas, sem depender de WSL.
