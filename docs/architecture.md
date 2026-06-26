# Arquitetura

## Visão geral

O projeto é dividido em camadas de responsabilidade, não em um único fluxo preso ao Windows:

1. Host suportado.
2. Orquestrador do host.
3. Ambiente Linux gerenciado.
4. Configurações compartilhadas.

No escopo atual, o host suportado é Windows 11. O PowerShell é o orquestrador porque instala e configura componentes que existem fora do WSL, como WezTerm, VS Code, WSL e `.wslconfig`.

O Ubuntu/WSL é o ambiente Linux gerenciado e é configurado por scripts Bash chamados a partir do PowerShell.

No escopo futuro, Ubuntu nativo poderá ser um host suportado. Nesse caso, Bash será o orquestrador do host, e as configurações Linux serão aplicadas localmente, sem WSL.

## Fluxo planejado atual: Windows 11 host

```text
install.ps1 remoto
|
|-- baixa ZIP do repositório público
|-- extrai em pasta temporária
`-- executa bootstrap.ps1

bootstrap.ps1
|
|-- verifica pré-requisitos Windows
|-- se -Reset, executa fluxo de reset controlado
|-- instala/configura WSL2
|-- instala/configura Ubuntu no WSL
|-- gera .wslconfig
|-- instala apps Windows via winget
|-- instala fontes
|-- configura WezTerm
|-- configura VS Code
`-- chama scripts/ubuntu/bootstrap.sh dentro do WSL

scripts/ubuntu/bootstrap.sh
|
|-- instala pacotes apt
|-- configura zsh
|-- configura Starship
|-- configura aliases e ferramentas
`-- exibe validações
```

## Fluxo futuro: Ubuntu host

TODO:

```text
install.sh remoto
|
|-- baixa arquivo ou ZIP do repositório público
|-- extrai em diretório temporário
`-- executa bootstrap.sh

bootstrap.sh
|
|-- verifica pré-requisitos Ubuntu host
|-- detecta apt e versão da distribuição
|-- instala pacotes host
|-- instala/configura terminal/editor/fontes quando aplicável
|-- aplica config/zsh/.zshrc
|-- aplica config/starship/starship.toml
`-- exibe validações
```

## Fluxo de reset controlado

O reset é um modo operacional separado do bootstrap normal.

```text
bootstrap.ps1 -Reset
|
|-- valida ResetScope
|-- calcula ações aplicáveis ao host atual
|-- exige ConfirmDestructive para ações destrutivas
|-- executa DryRun ou aplica mudanças
|-- restaura backups quando possível
`-- exibe resumo de executado, ignorado e pendente
```

O reset não deve pressupor que tudo instalado na máquina pertence ao projeto. Sempre que possível, deve usar marcadores, backups ou estado exportado para identificar o que é gerenciado.

## Estrutura

```text
workstation-bootstrap/
|-- README.md
|-- AGENTS.md
|-- install.ps1
|-- bootstrap.ps1
|-- config/
|-- packages/
|-- scripts/
|   |-- windows/
|   `-- ubuntu/
|-- docs/
`-- TODO: install.sh / bootstrap.sh para Ubuntu host
```

## Responsabilidades

### `install.ps1`

Instalador remoto para Windows. Não depende de clone prévio.

### `bootstrap.ps1`

Orquestrador principal do host Windows.

Também deve expor o modo `-Reset` para retestes controlados no host Windows.

### `scripts/windows/`

Scripts especializados para tarefas do host Windows.

### `scripts/ubuntu/`

Scripts especializados para tarefas Ubuntu. Hoje eles rodam dentro do WSL. No futuro, devem ser reutilizáveis pelo fluxo Ubuntu host quando não dependerem de WSL.

### `config/`

Arquivos de configuração versionados. Deve conter configurações compartilhadas e configurações específicas de host com nomes claros.

### `packages/`

Listas declarativas de programas e pacotes. Pacotes específicos de host devem ficar em arquivos separados.

## Idempotência

Cada script deve verificar estado atual antes de agir.

Exemplos:

- Se WezTerm já estiver instalado, não reinstalar sem necessidade.
- Se Ubuntu no WSL já existir, não recriar distribuição.
- Se `.zshrc` já existir, criar backup antes de substituir.
- Se pacote apt já estiver instalado, ignorar.
- Se uma etapa não se aplica ao host atual, registrar como ignorada.

## Reset

Reset não é o inverso cego do bootstrap. Ele é uma operação controlada para reteste e deve:

- exigir escopo explícito;
- respeitar `DryRun`;
- preservar backups;
- preferir restaurar ao apagar;
- exigir confirmação para remoções destrutivas;
- registrar itens ignorados por não serem comprovadamente gerenciados pelo projeto.

## Perfis

Perfis ficam em `config/workstation.json`.

Perfis iniciais:

- `personal`;
- `corporate`;
- `minimal`.

Perfis devem controlar ferramentas por capacidade e por plataforma, não por suposições implícitas sobre Windows.
