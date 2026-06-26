# Arquitetura

## Visão geral

O projeto é dividido em duas camadas:

1. Host Windows.
2. Ubuntu dentro do WSL.

O Windows é o orquestrador principal porque instala e configura componentes que existem fora do WSL, como WezTerm, VS Code, WSL e `.wslconfig`.

O Ubuntu/WSL é configurado por scripts Bash chamados a partir do PowerShell.

## Fluxo planejado

```text
install.ps1 remoto
│
├── baixa ZIP do repositório público
├── extrai em pasta temporária
└── executa bootstrap.ps1

bootstrap.ps1
│
├── verifica pré-requisitos Windows
├── instala/configura WSL2
├── instala/configura Ubuntu
├── gera .wslconfig
├── instala apps Windows via winget
├── instala fontes
├── configura WezTerm
├── configura VS Code
└── chama scripts/ubuntu/bootstrap.sh dentro do WSL

scripts/ubuntu/bootstrap.sh
│
├── instala pacotes apt
├── configura zsh
├── configura Starship
├── configura aliases e ferramentas
└── exibe validações
```

## Estrutura

```text
workstation-bootstrap/
├── README.md
├── AGENTS.md
├── install.ps1
├── bootstrap.ps1
├── config/
├── packages/
├── scripts/
└── docs/
```

## Responsabilidades

### `install.ps1`

Instalador remoto. Não depende de clone prévio.

### `bootstrap.ps1`

Orquestrador principal.

### `scripts/windows/`

Scripts especializados para tarefas Windows.

### `scripts/ubuntu/`

Scripts especializados para tarefas Ubuntu/WSL.

### `config/`

Arquivos de configuração versionados.

### `packages/`

Listas declarativas de programas e pacotes.

## Idempotência

Cada script deve verificar estado atual antes de agir.

Exemplos:

- Se WezTerm já estiver instalado, não reinstalar sem necessidade.
- Se Ubuntu já existir, não recriar distribuição.
- Se `.zshrc` já existir, criar backup antes de substituir.
- Se pacote apt já estiver instalado, ignorar.

## Perfis

Perfis ficam em `config/workstation.json`.

Perfis iniciais:

- `personal`;
- `corporate`;
- `minimal`.
