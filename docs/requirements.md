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
16. Reset controlado para retestes, com escopo explícito e confirmação para ações destrutivas.

Estado atual: esses objetivos estão implementados para Windows 11 + WSL2 + Ubuntu, com exceção do reset `UbuntuTools`, que permanece conservador e não remove pacotes `apt` por falta de rastreio confiável de ownership por pacote.

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

Regras:

- instalar apenas entradas com `enabled: true`;
- detectar apps já instalados antes de chamar `winget install`;
- não registrar apps pré-existentes como gerenciados pelo projeto;
- registrar no manifesto apenas apps instalados pelo projeto;
- respeitar `-DryRun` e `-SkipWindowsApps`.

Limitação atual: `config/workstation.json` declara `installWindowsApps`, mas o fluxo Windows usa `packages/windows.json` e o parâmetro `-SkipWindowsApps` como controles efetivos.

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

Limitação atual: `config/workstation.json` declara `installUbuntuPackages`, mas o controle efetivo é `-SkipUbuntuPackages`, repassado ao bootstrap Ubuntu.

## Parâmetros esperados no Windows

`bootstrap.ps1` aceita:

```powershell
-DryRun
-SkipWSL
-SkipWindowsApps
-SkipUbuntuPackages
-Export
-Reset
-ResetScope Config|UbuntuTools|WSLDistro|WindowsApps|All
-ConfirmDestructive
-Profile personal|corporate|minimal
```

`install.ps1` aceita os mesmos parâmetros principais, baixa o ZIP do repositório quando não há clone local e repassa a execução para `bootstrap.ps1`. Quando executado dentro de um clone, detecta o `bootstrap.ps1` local. Quando executado via `irm ... | iex`, não depende de `$PSScriptRoot`.

## Perfis Windows

`-Profile personal|corporate|minimal` é aceito, validado contra `config/workstation.json` e registrado no manifesto local.

Limitação atual: os perfis ainda não alteram capacidades, pacotes, aplicativos ou configurações aplicadas. Essa diferenciação permanece pendente.

## Parâmetros futuros no Ubuntu host

TODO: `bootstrap.sh` deve aceitar equivalentes em Bash:

```bash
--dry-run
--skip-host-apps
--skip-ubuntu-packages
--export
--reset
--reset-scope config|ubuntu-tools|host-apps|all
--confirm-destructive
--profile personal|corporate|minimal
```

## Segurança

- Não sobrescrever arquivos sem backup.
- Não executar comandos destrutivos sem confirmação explícita.
- Não imprimir credenciais.
- Implementar modo `DryRun`.
- Tratar erros claramente.
- Isolar ações específicas de cada host.
- Reset nunca deve desinstalar tudo por padrão.
- Ações destrutivas devem exigir escopo explícito e confirmação explícita.
- O reset deve distinguir itens gerenciados pelo projeto de itens existentes na máquina antes do bootstrap.

## Reset controlado

O projeto deve suportar retestes sem exigir reinstalação manual da máquina inteira.

Requisitos:

1. `-Reset` ativa o modo de reset.
2. `-ResetScope` define exatamente o que será resetado.
3. `-DryRun` deve mostrar ações planejadas sem modificar a máquina.
4. `-ConfirmDestructive` deve ser obrigatório para remover distro WSL, desinstalar aplicativos ou apagar configurações sem restauração.
5. O resumo final deve listar ações executadas, ignoradas e pendentes.
6. Quando possível, restaurar backups em vez de apagar arquivos.
7. Pacotes e aplicativos não devem ser removidos se não houver evidência de que são gerenciados pelo projeto.
8. O reset de pacotes Ubuntu deve ser conservador enquanto não houver rastreio confiável de ownership por pacote.

Escopos iniciais no Windows:

| Escopo | Intenção | Confirmação destrutiva |
| --- | --- | --- |
| `Config` | Restaurar/remover configs gerenciadas pelo projeto. | Depende da ação. |
| `UbuntuTools` | Registrar pendência conservadora para ferramentas Ubuntu. | Sem remoções automáticas no estado atual. |
| `WSLDistro` | Remover distro WSL gerenciada para reteste limpo. | Sempre. |
| `WindowsApps` | Desinstalar apps Windows gerenciados. | Sempre. |
| `All` | Reset amplo dos escopos suportados. | Sempre. |

## Backups

Antes de substituir arquivos, criar backup com timestamp.

Exemplos:

```text
.zshrc.backup-20260626-153000
starship.toml.backup-20260626-153000
wezterm.lua.backup-20260626-153000
.wslconfig.backup-20260626-153000
```

## `.wslconfig`

Regras:

- gerar a partir de `config/wsl/wslconfig.template`;
- calcular memória, processadores e swap de forma conservadora;
- preservar `.wslconfig` existente se os dados de hardware não puderem ser lidos com segurança;
- criar backup com timestamp antes de substituir arquivo existente;
- não reescrever quando o conteúdo já estiver atualizado;
- respeitar `-DryRun` e `-SkipWSL`;
- registrar arquivo aplicado e backups no manifesto.

## WSL e Ubuntu

Regras:

- detectar `wsl.exe` antes de tentar instalar;
- listar distros existentes com `wsl --list --quiet`;
- usar `config/workstation.json` para escolher a distro alvo;
- não recriar distro existente;
- não registrar distro pré-existente como gerenciada pelo projeto;
- registrar no manifesto apenas distro criada pelo projeto;
- respeitar `-DryRun` e `-SkipWSL`;
- informar quando uma reinicialização do Windows puder ser necessária.

## WezTerm

Regras:

- aplicar `config/wezterm/wezterm.lua` em `%USERPROFILE%\.config\wezterm\wezterm.lua`;
- criar diretório de destino quando necessário;
- criar backup com timestamp antes de substituir configuração existente;
- não reescrever quando o conteúdo já estiver atualizado;
- respeitar `-DryRun`;
- registrar arquivo aplicado e backups no manifesto.

## Fontes

Regras:

- instalar JetBrainsMono Nerd Font para o usuário atual quando ausente;
- detectar fonte existente antes de baixar ou copiar arquivos;
- não registrar fonte pré-existente como gerenciada pelo projeto;
- registrar no manifesto apenas fontes instaladas pelo projeto;
- respeitar `-DryRun`.

Limitação atual: `config/workstation.json` declara `installFonts`, mas o fluxo Windows ainda não usa essa flag para desabilitar a etapa; use `-DryRun` para validar e ajuste o código antes de tratar esse campo como contrato operacional.

## VS Code

Regras:

- instalar extensões declaradas em `packages/vscode-extensions.txt`;
- detectar extensões já instaladas antes de chamar `code --install-extension`;
- não registrar extensões pré-existentes como gerenciadas pelo projeto;
- registrar no manifesto apenas extensões instaladas pelo projeto;
- respeitar `-DryRun`.

## Bootstrap Ubuntu no WSL

Regras:

- executar `scripts/ubuntu/bootstrap.sh` dentro da distro WSL configurada;
- aceitar `--dry-run`;
- aceitar `--skip-ubuntu-packages`;
- não travar aguardando senha de `sudo`;
- quando `sudo` não estiver disponível de forma não interativa, registrar pendência com comando manual;
- aplicar `.zshrc` e `starship.toml` com backup;
- configurar `git init.defaultBranch=main`;
- validar ferramentas modernas após instalação.

## Export

Regras:

- exportar para `exports/<timestamp>/`;
- copiar manifesto local quando existir;
- exportar snapshot do host;
- exportar lista `winget`;
- exportar status/lista WSL;
- exportar extensões VS Code;
- copiar `.wslconfig` e `wezterm.lua` aplicados quando existirem;
- respeitar `-DryRun`;
- atualizar o manifesto com o último caminho exportado.

## Resultado esperado atual

Ao final do fluxo Windows, abrir o WezTerm no Windows deve levar diretamente ao Ubuntu/WSL usando zsh com Starship configurado, fonte Nerd Font e ferramentas modernas instaladas.

## Resultado esperado futuro

TODO: ao final do fluxo Ubuntu host, abrir o terminal configurado no Ubuntu nativo deve usar zsh com Starship e as mesmas ferramentas modernas, sem depender de WSL.
