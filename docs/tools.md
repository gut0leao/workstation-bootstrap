# Ferramentas

As ferramentas são classificadas entre ferramentas do host e ferramentas do ambiente Linux.

## WezTerm

Terminal moderno usado no escopo atual como interface principal do host Windows para o Ubuntu/WSL.

TODO: decidir se WezTerm também será o terminal padrão no Ubuntu host ou se outro terminal será suportado primeiro.

## WSL2

Camada de compatibilidade Linux integrada ao Windows.

É específica do host Windows e não deve ser exigida quando o host futuro for Ubuntu nativo.

## Ubuntu

Distribuição Linux principal para desenvolvimento.

No escopo atual, roda dentro do WSL. No escopo futuro, também poderá ser o próprio host.

## VS Code

Editor principal no escopo atual, instalado no Windows e integrado ao WSL.

Uso típico dentro do WSL:

```bash
code .
```

TODO: definir estratégia de instalação e configuração do VS Code no Ubuntu host.

## zsh

Shell interativo mais produtivo que o bash para uso diário.

Configuração compartilhada entre Ubuntu/WSL e Ubuntu host futuro.

## Starship

Prompt moderno e contextual.

Mostra informações úteis como diretório, branch Git, status Git, linguagens e duração de comandos.

Configuração compartilhada entre Ubuntu/WSL e Ubuntu host futuro.

## eza

Substituto moderno do `ls`.

```bash
eza -lah --git
```

## zoxide

Navegação inteligente por diretórios.

```bash
z nome-do-projeto
```

## fzf

Busca interativa.

Uso mais comum:

```text
Ctrl+R
```

## bat

Alternativa ao `cat` com syntax highlight.

```bash
bat arquivo.py
```

No Ubuntu, o binário pode ser `batcat`.

## ripgrep

Busca textual rápida.

```bash
rg termo
```

## fd

Alternativa simples ao `find`.

```bash
fd composer
```

No Ubuntu, o binário pode ser `fdfind`.

## btop

Monitor de recursos.

```bash
btop
```

## direnv

Carrega variáveis de ambiente automaticamente por diretório.

```bash
direnv allow
```
