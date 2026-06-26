# Decisões Arquiteturais

## 001 — Nome do projeto

Decisão: usar `workstation-bootstrap`.

Justificativa: o projeto configura uma workstation de desenvolvimento, não apenas Windows ou WSL. O nome permite evolução futura para outros sistemas e perfis.

## 002 — Plataforma implementada inicialmente

Decisão: implementar primeiro Windows 11 como host, com WSL2 e Ubuntu como ambiente Linux gerenciado.

Justificativa: esse é o ambiente inicial que será testado agora. Limitar a primeira implementação reduz risco e evita generalização prematura.

## 003 — Arquitetura preparada para múltiplos hosts

Decisão: documentação, nomes e responsabilidades devem distinguir host, orquestrador e ambiente Linux gerenciado.

Justificativa: o projeto deve poder evoluir para Ubuntu host nativo sem reescrever sua identidade e sem misturar responsabilidades específicas do Windows com configurações Linux reutilizáveis.

## 004 — PowerShell como orquestrador do host Windows

Decisão: o ponto de entrada implementado agora é PowerShell no Windows.

Justificativa: WSL, Ubuntu no WSL, `.wslconfig`, WezTerm, VS Code e fontes pertencem ao host Windows. Portanto, o bootstrap Windows deve começar no PowerShell.

## 005 — Bash como orquestrador futuro do host Ubuntu

Decisão: quando Ubuntu nativo for suportado como host, o ponto de entrada deve ser Bash.

Justificativa: scripts Linux devem ser naturais ao ambiente Linux e não depender de PowerShell, WSL ou `winget`.

## 006 — Ubuntu como ambiente Linux principal

Decisão: ferramentas Linux de desenvolvimento serão instaladas inicialmente dentro do Ubuntu/WSL e, futuramente, no Ubuntu host nativo.

Justificativa: manter Ubuntu como primeiro alvo Linux reduz a matriz de testes e permite reutilizar pacotes e configurações.

## 007 — zsh sem Oh My Zsh

Decisão: usar zsh limpo, sem Oh My Zsh.

Justificativa: reduz complexidade, melhora previsibilidade e evita plugins desnecessários.

## 008 — Starship como prompt

Decisão: usar Starship para prompt contextual.

Justificativa: fornece contexto útil de Git, linguagens e execução de comandos com configuração simples e portátil.

## 009 — Arquivos de configuração versionados

Decisão: manter `.zshrc`, `starship.toml`, `wezterm.lua` e template de `.wslconfig` no repositório.

Justificativa: transforma a configuração da workstation em fonte da verdade versionada.

## 010 — Backups obrigatórios

Decisão: nenhum arquivo de configuração existente deve ser sobrescrito sem backup com timestamp.

Justificativa: segurança e reversibilidade.
