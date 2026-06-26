# Workstation Bootstrap

**Workstation Bootstrap** é um projeto de *Infrastructure as Code (IaC)* para estações de trabalho de desenvolvimento.

O objetivo é permitir que uma máquina nova seja provisionada de forma reproduzível, segura e modular, transformando a configuração da workstation em código versionado.

O projeto deve ser desenhado para suportar mais de uma plataforma host ao longo do tempo. O escopo implementado agora é:

- host Windows 11;
- PowerShell como orquestrador no Windows;
- WSL2;
- Ubuntu dentro do WSL como ambiente Linux gerenciado;
- WezTerm;
- VS Code;
- zsh;
- Starship;
- ferramentas modernas de terminal.

## Objetivo

Configurar uma workstation de desenvolvimento com o menor número possível de comandos, instalando e configurando componentes do host suportado e do ambiente Linux gerenciado.

No escopo atual, isso significa configurar o host Windows 11 e o Ubuntu/WSL. A arquitetura e a documentação devem manter espaço explícito para que, no futuro, o mesmo projeto possa ser executado a partir de um Ubuntu nativo como host.

O projeto deve permitir:

- instalação remota sem clone prévio;
- instalação após clone manual;
- execução idempotente;
- backup antes de sobrescrever configurações;
- perfis de instalação;
- exportação da configuração atual da workstation;
- reset controlado para retestes;
- inclusão e remoção simples de ferramentas;
- separação clara entre responsabilidades do host e do ambiente Linux;
- evolução futura para Ubuntu como host nativo.

## Plataformas

| Host | Estado | Orquestrador | Ambiente Linux alvo |
| --- | --- | --- | --- |
| Windows 11 | Implementado | PowerShell | Ubuntu via WSL2 |
| Ubuntu nativo | Futuro/TODO | Bash | Ubuntu local |
| macOS | Fora do escopo atual | A definir | A definir |

Consulte [`docs/platforms.md`](docs/platforms.md) para o contrato de plataformas e os TODOs de expansão.

## Uso rápido

```powershell
irm https://raw.githubusercontent.com/gut0leao/workstation-bootstrap/main/install.ps1 | iex
```

## Uso recomendado

```powershell
iwr https://raw.githubusercontent.com/gut0leao/workstation-bootstrap/main/install.ps1 -OutFile install.ps1
notepad install.ps1
.\install.ps1
```

`install.ps1` também pode ser executado dentro de um clone; nesse caso ele detecta o `bootstrap.ps1` local e repassa os parâmetros.

## Uso após clone

```powershell
git clone https://github.com/gut0leao/workstation-bootstrap.git
cd workstation-bootstrap
.\bootstrap.ps1
```

## Estado atual da implementação

O bootstrap Windows já executa uma base funcional:

- executa remotamente via `irm ... | iex` sem clone prévio;
- carrega `config/workstation.json`;
- mantém manifesto local em `%LOCALAPPDATA%\workstation-bootstrap\state.json`;
- verifica pré-requisitos do host Windows;
- instala aplicativos Windows habilitados em `packages/windows.json` via `winget`;
- gera `%USERPROFILE%\.wslconfig` a partir de `config/wsl/wslconfig.template`;
- detecta a distro WSL configurada e prepara instalação quando ela não existe;
- aplica `config/wezterm/wezterm.lua` em `%USERPROFILE%\.config\wezterm\wezterm.lua`;
- instala JetBrainsMono Nerd Font para o usuário atual quando ausente;
- instala extensões VS Code declaradas em `packages/vscode-extensions.txt`;
- executa `scripts/ubuntu/bootstrap.sh` dentro da distro WSL configurada;
- exporta estado e configurações atuais para `exports/<timestamp>/`;
- respeita `-DryRun`;
- respeita `-SkipWindowsApps`;
- respeita `-SkipWSL`;
- respeita `-SkipUbuntuPackages` ao chamar o bootstrap Ubuntu;
- não marca aplicativos já existentes como gerenciados pelo projeto.

Limitações atuais:

- `-Profile personal|corporate|minimal` é aceito e registrado, mas os perfis ainda não alteram capacidades ou listas de ferramentas.
- `UbuntuTools` no reset é conservador e não remove pacotes `apt`, pois ainda não há rastreio confiável de ownership por pacote.
- Ubuntu nativo como host continua planejado, não implementado.

Exportação:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\bootstrap.ps1 -Export
```

Validação sem instalar nada:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\bootstrap.ps1 -DryRun
```

## Arquitetura geral

```text
Host suportado
|
|-- Orquestrador do host
|-- Gerenciador de pacotes do host
|-- Aplicativos gráficos/opcionais do host
|-- Terminal/editor/fontes do host
`-- Ambiente Linux gerenciado

Escopo atual: Windows 11 host
|
|-- PowerShell bootstrap
|-- winget
|-- WSL2
|-- Ubuntu no WSL
|-- WezTerm
|-- VS Code
|-- Nerd Fonts
`-- .wslconfig

Ambiente Linux gerenciado: Ubuntu
|
|-- zsh
|-- Starship
|-- eza
|-- zoxide
|-- fzf
|-- bat
|-- ripgrep
|-- fd
|-- btop
|-- direnv
`-- ferramentas de desenvolvimento
```

## Documentação

- [`AGENTS.md`](AGENTS.md): instruções para agentes de IA.
- [`docs/vision.md`](docs/vision.md): visão e filosofia do projeto.
- [`docs/requirements.md`](docs/requirements.md): requisitos funcionais e técnicos.
- [`docs/architecture.md`](docs/architecture.md): arquitetura planejada.
- [`docs/platforms.md`](docs/platforms.md): contrato de plataformas, escopo atual e TODOs para Ubuntu host.
- [`docs/reset.md`](docs/reset.md): política de reset controlado para retestes.
- [`docs/roadmap.md`](docs/roadmap.md): evolução futura.
- [`docs/decisions.md`](docs/decisions.md): decisões arquiteturais.
- [`docs/tools.md`](docs/tools.md): ferramentas previstas e dicas de uso.
- [`docs/troubleshooting.md`](docs/troubleshooting.md): problemas comuns.
- [`docs/profiles.md`](docs/profiles.md): perfis de instalação.

## Primeira implementação atual

A primeira versão funcional implementa apenas o fluxo Windows 11 + WSL2 + Ubuntu:

1. `install.ps1` para instalação remota no Windows.
2. `bootstrap.ps1` como orquestrador principal do host Windows.
3. Verificações do Windows 11, PowerShell, admin, winget e WSL.
4. Instalação do WezTerm e VS Code via `winget`.
5. Geração de `.wslconfig` baseada no hardware.
6. Detecção/instalação conservadora do WSL2 e Ubuntu.
7. Configuração do WezTerm usando `default_prog` com `wsl.exe -d Ubuntu --cd ~`, além de menu/atalhos para PowerShell, CMD e Ubuntu.
8. Instalação de JetBrainsMono Nerd Font quando ausente.
9. Instalação de extensões VS Code declaradas.
10. Execução do bootstrap Linux dentro do Ubuntu/WSL.
11. Instalação/configuração de zsh, Starship e ferramentas de terminal.
12. Reset controlado para retestar o ambiente sem desinstalar tudo por padrão.

## Reset controlado

O projeto não oferece um comando que desinstala tudo implicitamente. Para retestar a criação do ambiente na mesma máquina, existe um modo de reset com escopo explícito:

```powershell
.\bootstrap.ps1 -Reset -ResetScope Config -DryRun
.\bootstrap.ps1 -Reset -ResetScope WSLDistro -ConfirmDestructive
```

Escopos atuais:

- `Config`: restaura ou remove configurações gerenciadas pelo projeto.
- `UbuntuTools`: registra pendência conservadora; pacotes `apt` não são removidos automaticamente.
- `WSLDistro`: remove uma distro WSL gerenciada pelo projeto, exigindo confirmação destrutiva.
- `WindowsApps`: desinstala aplicativos Windows gerenciados pelo projeto, exigindo confirmação destrutiva.
- `All`: executa reset amplo, sempre com confirmação destrutiva e resumo detalhado.

Consulte [`docs/reset.md`](docs/reset.md).

Validação sem remover nada:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\bootstrap.ps1 -Reset -ResetScope All -DryRun
```

## TODOs de plataforma

- Criar `install.sh` para Ubuntu host nativo.
- Criar `bootstrap.sh` de host Linux, separado de `scripts/ubuntu/bootstrap.sh`.
- Separar pacotes Ubuntu de uso geral dos pacotes específicos de WSL.
- Criar lista de aplicativos de desktop Linux em `packages/ubuntu-desktop.*`.
- Definir estratégia para VS Code no Ubuntu host.
- Definir estratégia para terminal no Ubuntu host.
- Adaptar backups para caminhos Linux nativos.
- Criar validações para Ubuntu host sem WSL.
- Garantir que configurações compartilhadas, como zsh e Starship, possam ser aplicadas tanto no WSL quanto no Ubuntu host.

## Validações esperadas

No host Windows:

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

- `config/wezterm/wezterm.lua`: configuração do WezTerm para o escopo Windows usando `default_prog` com `wsl.exe`, tema Tokyo Night, Acrylic, JetBrainsMono Nerd Font, launch menu e atalhos para copiar (`Ctrl+Shift+C`), PowerShell (`Ctrl+Shift+P`), CMD (`Ctrl+Shift+D`) e Ubuntu no diretório atual (`Ctrl+Shift+U`).
- `config/zsh/.zshrc`: zsh limpo, sem Oh My Zsh, com histórico, autocomplete, aliases e integração condicional com zoxide, direnv e Starship.
- `config/starship/starship.toml`: prompt minimalista e contextual para Git, Python, Node, PHP, Ruby, Docker e duração de comandos.

## Publicação no GitHub

Repositório público:

```text
https://github.com/gut0leao/workstation-bootstrap
```

O branch principal é `main`.
