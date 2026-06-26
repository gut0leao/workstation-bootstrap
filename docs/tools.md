# Ferramentas

## WezTerm

Terminal moderno usado no Windows como interface principal para o Ubuntu/WSL.

## WSL2

Camada de compatibilidade Linux integrada ao Windows.

## Ubuntu

Distribuição Linux principal para desenvolvimento.

## VS Code

Editor principal no Windows, integrado ao WSL.

Uso típico dentro do WSL:

```bash
code .
```

## zsh

Shell interativo mais produtivo que o bash para uso diário.

## Starship

Prompt moderno e contextual.

Mostra informações úteis como diretório, branch Git, status Git, linguagens e duração de comandos.

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
