# Decisões Arquiteturais

## 001 — Nome do projeto

Decisão: usar `workstation-bootstrap`.

Justificativa: o projeto configura uma workstation de desenvolvimento, não apenas Windows ou WSL. O nome permite evolução futura para outros sistemas e perfis.

## 002 — Windows como orquestrador principal

Decisão: o ponto de entrada principal será PowerShell no Windows.

Justificativa: WSL, Ubuntu, `.wslconfig`, WezTerm, VS Code e fontes pertencem ao host Windows. Portanto, o bootstrap deve começar no Windows.

## 003 — Ubuntu/WSL como ambiente principal de desenvolvimento

Decisão: ferramentas Linux de desenvolvimento serão instaladas dentro do Ubuntu/WSL.

Justificativa: o fluxo principal de desenvolvimento usa Linux via WSL.

## 004 — zsh sem Oh My Zsh

Decisão: usar zsh limpo, sem Oh My Zsh.

Justificativa: reduz complexidade, melhora previsibilidade e evita plugins desnecessários.

## 005 — Starship como prompt

Decisão: usar Starship para prompt contextual.

Justificativa: fornece contexto útil de Git, linguagens e execução de comandos com configuração simples e portável.

## 006 — Arquivos de configuração versionados

Decisão: manter `.zshrc`, `starship.toml`, `wezterm.lua` e template de `.wslconfig` no repositório.

Justificativa: transforma a configuração da workstation em fonte da verdade versionada.

## 007 — Backups obrigatórios

Decisão: nenhum arquivo de configuração existente deve ser sobrescrito sem backup com timestamp.

Justificativa: segurança e reversibilidade.
