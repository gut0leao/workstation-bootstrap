# AGENTS.md

Este projeto é mantido em parceria entre o desenvolvedor humano e agentes de IA, como Codex e ChatGPT.

## Princípios

- Priorizar clareza em vez de mágica.
- Scripts Windows devem ser escritos em PowerShell.
- Scripts Linux devem ser escritos em Bash.
- A primeira plataforma alvo é Windows 11 + WSL2 + Ubuntu.
- O PowerShell no Windows é o orquestrador principal.
- O Ubuntu/WSL é o ambiente principal de desenvolvimento.
- Toda alteração deve ser idempotente.
- Rodar o bootstrap mais de uma vez não deve quebrar o ambiente.
- Nunca sobrescrever arquivos de configuração sem backup.
- Sempre criar backups com timestamp antes de substituir configurações existentes.
- Toda ferramenta deve poder ser habilitada ou desabilitada por configuração.
- Manter separação clara entre host Windows e Ubuntu/WSL.
- Preferir soluções oficiais ou amplamente adotadas.
- Tratar erros com mensagens legíveis.
- Não executar comandos destrutivos sem confirmação explícita.
- Não imprimir tokens, senhas ou credenciais.
- Manter o README atualizado sempre que o comportamento do projeto mudar.
- Atualizar a documentação em `docs/` quando decisões arquiteturais forem tomadas.

## Estilo de implementação

- Código simples, legível e comentado quando necessário.
- Evitar dependências desnecessárias.
- Evitar acoplamento forte entre módulos.
- Preferir funções pequenas em PowerShell e Bash.
- Implementar `-DryRun` em operações relevantes.
- Exibir resumo final com ações executadas, ignoradas e pendentes.

## Convenções

- O nome do projeto é `workstation-bootstrap`.
- O repositório público esperado é `thefordexter/workstation-bootstrap`.
- O branch principal esperado é `main`.
- Configurações versionadas ficam em `config/`.
- Listas de pacotes ficam em `packages/`.
- Scripts Windows ficam em `scripts/windows/`.
- Scripts Ubuntu ficam em `scripts/ubuntu/`.

## Tarefa inicial para agentes

Antes de implementar código, leia:

1. `README.md`;
2. `docs/vision.md`;
3. `docs/requirements.md`;
4. `docs/architecture.md`;
5. `docs/decisions.md`.

Depois implemente incrementalmente, validando cada etapa.
